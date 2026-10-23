//
//  APIClient.swift
//  NeuroPulseAI
//
//  HTTP API Client for the NeuroPulseAI FastAPI Backend.
//  Handles JWT Bearer tokens, structured error parsing, and dependency injection.
//

import Foundation

// MARK: - API DTO Models

public struct UserDTO: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let email: String
    public let isActive: Bool?
    public let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case isActive = "is_active"
        case createdAt = "created_at"
    }
}

public struct AuthResponseDTO: Codable, Sendable {
    public let accessToken: String
    public let tokenType: String
    public let user: UserDTO
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case user
    }
}

public struct ConsentResponseDTO: Codable, Sendable {
    public let id: String
    public let userId: String
    public let purpose: String
    public let decision: String
    public let version: String
    public let decisionTimestamp: String
    public let withdrawalTimestamp: String?
    public let currentStatus: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case purpose
        case decision
        case version
        case decisionTimestamp = "decision_timestamp"
        case withdrawalTimestamp = "withdrawal_timestamp"
        case currentStatus = "current_status"
    }
}

public struct ConsentDecisionRequestDTO: Codable, Sendable {
    public let decision: String
    public let version: String
    public let purpose: String
    
    public init(decision: String, version: String = "1.0", purpose: String = "personalization") {
        self.decision = decision
        self.version = version
        self.purpose = purpose
    }
}

public struct MotorSessionSyncItemDTO: Codable, Sendable {
    public let localId: String
    public let testType: String
    public let startedAt: String?
    public let completedAt: String
    public let durationSeconds: Double?
    public let cadenceTapsPerSec: Double?
    public let intervalCv: Double?
    public let meanInterTapIntervalMs: Double?
    public let meanCenterDeviation: Double?
    public let meanAccuracyScore: Double?
    public let totalTaps: Int?
    public let spiralRmse: Double?
    public let spiralCompletionTimeSec: Double?
    
    enum CodingKeys: String, CodingKey {
        case localId = "local_id"
        case testType = "test_type"
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case durationSeconds = "duration_seconds"
        case cadenceTapsPerSec = "cadence_taps_per_sec"
        case intervalCv = "interval_cv"
        case meanInterTapIntervalMs = "mean_inter_tap_interval_ms"
        case meanCenterDeviation = "mean_center_deviation"
        case meanAccuracyScore = "mean_accuracy_score"
        case totalTaps = "total_taps"
        case spiralRmse = "spiral_rmse"
        case spiralCompletionTimeSec = "spiral_completion_time_sec"
    }
}

public struct WellnessSessionSyncItemDTO: Codable, Sendable {
    public let localId: String
    public let activityType: String
    public let startedAt: String?
    public let completedAt: String
    public let durationSeconds: Double?
    public let cyclesCompleted: Int?
    public let targetCycles: Int?
    public let stressRating: Int?
    public let energyRating: Int?
    public let moodRating: Int?
    
    enum CodingKeys: String, CodingKey {
        case localId = "local_id"
        case activityType = "activity_type"
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case durationSeconds = "duration_seconds"
        case cyclesCompleted = "cycles_completed"
        case targetCycles = "target_cycles"
        case stressRating = "stress_rating"
        case energyRating = "energy_rating"
        case moodRating = "mood_rating"
    }
}

public struct SyncBatchRequestDTO: Codable, Sendable {
    public let motorSessions: [MotorSessionSyncItemDTO]
    public let wellnessSessions: [WellnessSessionSyncItemDTO]
    
    enum CodingKeys: String, CodingKey {
        case motorSessions = "motor_sessions"
        case wellnessSessions = "wellness_sessions"
    }
}

public struct SyncBatchResponseDTO: Codable, Sendable {
    public let syncedMotorCount: Int
    public let syncedWellnessCount: Int
    public let existingMotorCount: Int
    public let existingWellnessCount: Int
    public let syncedAt: String
    
    enum CodingKeys: String, CodingKey {
        case syncedMotorCount = "synced_motor_count"
        case syncedWellnessCount = "synced_wellness_count"
        case existingMotorCount = "existing_motor_count"
        case existingWellnessCount = "existing_wellness_count"
        case syncedAt = "synced_at"
    }
}

public struct RecommendationItemDTO: Codable, Sendable, Identifiable {
    public var id: String { recommendationId }
    public let recommendationId: String
    public let title: String
    public let description: String
    public let category: String
    public let explanation: String
    public let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case recommendationId = "recommendation_id"
        case title
        case description
        case category
        case explanation
        case createdAt = "created_at"
    }
}

public struct RecommendationListResponseDTO: Codable, Sendable {
    public let userId: String
    public let hasSufficientData: Bool
    public let statusMessage: String
    public let recommendations: [RecommendationItemDTO]
    public let generatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case hasSufficientData = "has_sufficient_data"
        case statusMessage = "status_message"
        case recommendations
        case generatedAt = "generated_at"
    }
}

public struct RemoteDataDeletionResponseDTO: Codable, Sendable {
    public let status: String
    public let message: String
    public let deletedMotorSessions: Int
    public let deletedWellnessSessions: Int
    public let deletedRecommendations: Int
    public let consentWithdrawn: Bool
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
        case deletedMotorSessions = "deleted_motor_sessions"
        case deletedWellnessSessions = "deleted_wellness_sessions"
        case deletedRecommendations = "deleted_recommendations"
        case consentWithdrawn = "consent_withdrawn"
    }
}

// MARK: - API Client Protocol

public protocol APIClientProtocol: Sendable {
    func register(email: String, password: String) async throws -> AuthResponseDTO
    func login(email: String, password: String) async throws -> AuthResponseDTO
    func getProfile(token: String) async throws -> UserDTO
    func getConsent(token: String) async throws -> ConsentResponseDTO
    func setConsent(token: String, request: ConsentDecisionRequestDTO) async throws -> ConsentResponseDTO
    func withdrawConsent(token: String) async throws -> ConsentResponseDTO
    func syncSessions(token: String, batch: SyncBatchRequestDTO) async throws -> SyncBatchResponseDTO
    func getRecommendations(token: String) async throws -> RecommendationListResponseDTO
    func deleteRemoteData(token: String) async throws -> RemoteDataDeletionResponseDTO
}

// MARK: - API Client Implementation

public final class APIClient: APIClientProtocol, @unchecked Sendable {
    public static let shared = APIClient()
    
    public var baseURL: URL
    private let session: URLSession
    
    public init(baseURL: URL = URL(string: "http://127.0.0.1:8000")!, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    private func execute<T: Decodable>(
        path: String,
        method: String,
        body: Data? = nil,
        token: String? = nil
    ) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NSError(
                domain: "APIClient",
                code: -1004,
                userInfo: [NSLocalizedDescriptionKey: "Unable to connect to NeuroPulseAI server. Verify the server is running at \(baseURL.absoluteString)."]
            )
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(
                domain: "APIClient",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid server response."]
            )
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorDetail: String
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let detail = json["detail"] as? String {
                errorDetail = detail
            } else if let str = String(data: data, encoding: .utf8), !str.isEmpty {
                errorDetail = str
            } else {
                errorDetail = "HTTP Error \(httpResponse.statusCode)"
            }
            throw NSError(
                domain: "APIClient",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: errorDetail]
            )
        }
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NSError(
                domain: "APIClient",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Failed to decode response from server: \(error.localizedDescription)"]
            )
        }
    }
    
    public func register(email: String, password: String) async throws -> AuthResponseDTO {
        let body = try JSONSerialization.data(withJSONObject: ["email": email, "password": password])
        return try await execute(path: "auth/register", method: "POST", body: body)
    }
    
    public func login(email: String, password: String) async throws -> AuthResponseDTO {
        let body = try JSONSerialization.data(withJSONObject: ["email": email, "password": password])
        return try await execute(path: "auth/login", method: "POST", body: body)
    }
    
    public func getProfile(token: String) async throws -> UserDTO {
        return try await execute(path: "auth/me", method: "GET", token: token)
    }
    
    public func getConsent(token: String) async throws -> ConsentResponseDTO {
        return try await execute(path: "consent", method: "GET", token: token)
    }
    
    public func setConsent(token: String, request: ConsentDecisionRequestDTO) async throws -> ConsentResponseDTO {
        let encoder = JSONEncoder()
        let body = try encoder.encode(request)
        return try await execute(path: "consent/personalization", method: "PUT", body: body, token: token)
    }
    
    public func withdrawConsent(token: String) async throws -> ConsentResponseDTO {
        return try await execute(path: "consent/withdraw", method: "POST", token: token)
    }
    
    public func syncSessions(token: String, batch: SyncBatchRequestDTO) async throws -> SyncBatchResponseDTO {
        let encoder = JSONEncoder()
        let body = try encoder.encode(batch)
        return try await execute(path: "sessions/sync", method: "POST", body: body, token: token)
    }
    
    public func getRecommendations(token: String) async throws -> RecommendationListResponseDTO {
        return try await execute(path: "recommendations", method: "GET", token: token)
    }
    
    public func deleteRemoteData(token: String) async throws -> RemoteDataDeletionResponseDTO {
        return try await execute(path: "account/data", method: "DELETE", token: token)
    }
}
