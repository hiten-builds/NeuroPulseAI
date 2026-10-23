//
//  RecommendationService.swift
//  NeuroPulseAI
//
//  Provides explainable recommendations supporting two distinct paths:
//  - Mode A: Cloud personalization using authorized, consented records via FastAPI backend.
//  - Mode B: Deterministic on-device local guidance for local-only and unconsented users.
//  Strictly non-diagnostic: no disease probabilities or clinical claims.
//

import Foundation
import Combine

public struct RecommendationUIModel: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let description: String
    public let category: String
    public let explanation: String
    public let isCloudPersonalized: Bool
    public let evidenceSummary: String?
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        category: String,
        explanation: String,
        isCloudPersonalized: Bool,
        evidenceSummary: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.explanation = explanation
        self.isCloudPersonalized = isCloudPersonalized
        self.evidenceSummary = evidenceSummary
    }
}

@MainActor
public final class RecommendationService: ObservableObject {
    public static let shared = RecommendationService()
    
    @Published public private(set) var recommendations: [RecommendationUIModel] = []
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var hasSufficientData: Bool = true
    @Published public private(set) var statusMessage: String = ""
    @Published public var errorMessage: String? = nil
    
    private let apiClient: APIClientProtocol
    private let authManager: AuthManager
    private let consentManager: ConsentManager
    private let motorStore: MotorSessionStore
    private let wellnessStore: WellnessSessionStore
    
    public init(
        apiClient: APIClientProtocol = APIClient.shared,
        authManager: AuthManager = AuthManager.shared,
        consentManager: ConsentManager = ConsentManager.shared,
        motorStore: MotorSessionStore = MotorSessionStore.shared,
        wellnessStore: WellnessSessionStore = WellnessSessionStore.shared
    ) {
        self.apiClient = apiClient
        self.authManager = authManager
        self.consentManager = consentManager
        self.motorStore = motorStore
        self.wellnessStore = wellnessStore
    }
    
    public func loadRecommendations() async {
        isLoading = true
        errorMessage = nil
        let requestingAccountID = authManager.currentUser?.id
        
        // Check Operating Mode:
        // Mode A: Authenticated user with active data-sharing consent -> fetch from backend
        if authManager.currentMode == .authenticated && consentManager.isPersonalizationConsented {
            if let token = authManager.authToken, !token.isEmpty {
                do {
                    let response = try await apiClient.getRecommendations(token: token)
                    
                    // Race condition guard: ignore if user logged out or switched accounts
                    guard authManager.currentUser?.id == requestingAccountID else {
                        return
                    }
                    
                    hasSufficientData = response.hasSufficientData
                    statusMessage = response.statusMessage
                    
                    recommendations = response.recommendations.map { item in
                        RecommendationUIModel(
                            id: item.recommendationId,
                            title: item.title,
                            description: item.description,
                            category: item.category,
                            explanation: item.explanation,
                            isCloudPersonalized: true,
                            evidenceSummary: nil
                        )
                    }
                    isLoading = false
                    return
                } catch {
                    guard authManager.currentUser?.id == requestingAccountID else {
                        return
                    }
                    // In case of transient network error, fall back gracefully to local guidance
                    errorMessage = "Cloud recommendations unavailable: \(error.localizedDescription). Displaying local baseline guidance."
                }
            }
        }
        
        guard authManager.currentUser?.id == requestingAccountID || authManager.currentMode == .localOnly else {
            return
        }
        
        // Mode B: Local-only or unconsented mode -> Honest, deterministic on-device rules
        generateLocalGuidance()
        isLoading = false
    }
    
    private func generateLocalGuidance() {
        let motorCount = motorStore.records.count
        let wellnessCount = wellnessStore.records.count
        let total = motorCount + wellnessCount
        
        hasSufficientData = total >= 2
        
        if total < 2 {
            statusMessage = "Local baseline guidance. Complete 2 or more activities to observe patterns."
            recommendations = [
                RecommendationUIModel(
                    title: "Establish An Assessment Routine",
                    description: "Complete finger tapping and spiral tracing on consecutive days to observe natural hand motor consistency.",
                    category: "general",
                    explanation: "Baseline guidance: Single attempts do not capture day-to-day rhythm variation.",
                    isCloudPersonalized: false
                ),
                RecommendationUIModel(
                    title: "MindEase Relaxation Pause",
                    description: "Take 2 minutes for guided breathing in MindEase to reset your focus before motor assessments.",
                    category: "wellness",
                    explanation: "Mindful breathing supports relaxed muscle activation and focus.",
                    isCloudPersonalized: false
                )
            ]
        } else {
            statusMessage = "On-device guidance derived from \(total) saved local activities."
            var list: [RecommendationUIModel] = []
            
            // Analyze tapping rhythm
            let tapRecords = motorStore.records.filter { $0.testType == .tapping }
            if !tapRecords.isEmpty {
                let avgScore = tapRecords.map { $0.primaryScoreValue }.reduce(0, +) / Double(tapRecords.count)
                list.append(RecommendationUIModel(
                    title: "Rhythmic Alternation Pacing",
                    description: "Maintain a steady, comfortable posture while alternating taps between left and right targets.",
                    category: "cadence",
                    explanation: "Derived from \(tapRecords.count) local tapping sessions (average score: \(Int(avgScore))). Steady pacing promotes motor consistency.",
                    isCloudPersonalized: false
                ))
            }
            
            // Analyze spiral tracing
            let spiralRecords = motorStore.records.filter { $0.testType == .spiral }
            if !spiralRecords.isEmpty {
                list.append(RecommendationUIModel(
                    title: "Smooth Tracing Control",
                    description: "Focus on continuous line drawing rather than speed when tracing spiral loops.",
                    category: "tracing",
                    explanation: "Derived from \(spiralRecords.count) local spiral trials. Deliberate continuous movement improves precision.",
                    isCloudPersonalized: false
                ))
            }
            
            // Wellness pairing
            if wellnessCount > 0 {
                list.append(RecommendationUIModel(
                    title: "Mindful Recovery Practice",
                    description: "Continue pairing fine-motor assessments with relaxation activities in MindEase.",
                    category: "wellness",
                    explanation: "Derived from \(wellnessCount) completed local wellness sessions.",
                    isCloudPersonalized: false
                ))
            }
            
            recommendations = list
        }
    }
    
    public func clearOnSignOut() {
        recommendations = []
        isLoading = false
        statusMessage = ""
        errorMessage = nil
    }
}
