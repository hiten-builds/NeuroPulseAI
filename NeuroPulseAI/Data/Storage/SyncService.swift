//
//  SyncService.swift
//  NeuroPulseAI
//
//  Coordinates controlled synchronization between local stores and the authenticated backend.
//  Strictly enforces the consent gate: records are NEVER uploaded in local-only mode
//  or when consent is declined/withdrawn.
//

import Foundation
import Combine

public enum SyncState: String, Sendable {
    case idle
    case syncing
    case success
    case failed
    case consentDeclined
    case localOnly
}

@MainActor
public final class SyncService: ObservableObject {
    public static let shared = SyncService()
    
    @Published public private(set) var syncState: SyncState = .idle
    @Published public private(set) var lastSyncDate: Date? = nil
    @Published public private(set) var lastSyncError: String? = nil
    @Published public private(set) var syncedCount: Int = 0
    
    private let apiClient: APIClientProtocol
    private let authManager: AuthManager
    private let consentManager: ConsentManager
    private let motorStore: MotorSessionStore
    private let wellnessStore: WellnessSessionStore
    private let userDefaults: UserDefaults
    
    public init(
        apiClient: APIClientProtocol = APIClient.shared,
        authManager: AuthManager = AuthManager.shared,
        consentManager: ConsentManager = ConsentManager.shared,
        motorStore: MotorSessionStore = MotorSessionStore.shared,
        wellnessStore: WellnessSessionStore = WellnessSessionStore.shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.apiClient = apiClient
        self.authManager = authManager
        self.consentManager = consentManager
        self.motorStore = motorStore
        self.wellnessStore = wellnessStore
        self.userDefaults = userDefaults
    }
    
    private var activeAccountID: String? {
        authManager.currentUser?.id
    }
    
    private var syncedMotorIdsKey: String {
        if let id = activeAccountID {
            return "neuropulse_synced_motor_ids_\(id)"
        }
        return "neuropulse_synced_motor_ids_local"
    }
    
    private var syncedWellnessIdsKey: String {
        if let id = activeAccountID {
            return "neuropulse_synced_wellness_ids_\(id)"
        }
        return "neuropulse_synced_wellness_ids_local"
    }
    
    private var syncedMotorIds: Set<String> {
        get {
            let list = userDefaults.stringArray(forKey: syncedMotorIdsKey) ?? []
            return Set(list)
        }
        set {
            userDefaults.set(Array(newValue), forKey: syncedMotorIdsKey)
        }
    }
    
    private var syncedWellnessIds: Set<String> {
        get {
            let list = userDefaults.stringArray(forKey: syncedWellnessIdsKey) ?? []
            return Set(list)
        }
        set {
            userDefaults.set(Array(newValue), forKey: syncedWellnessIdsKey)
        }
    }
    
    public func isRecordSynced(id: UUID) -> Bool {
        let idStr = id.uuidString
        return syncedMotorIds.contains(idStr) || syncedWellnessIds.contains(idStr)
    }
    
    public func syncEligibleSessions() async {
        // 1. Consent Gate: Never upload if not authenticated or not consented
        guard authManager.currentMode == .authenticated else {
            syncState = .localOnly
            return
        }
        
        guard consentManager.isPersonalizationConsented else {
            syncState = .consentDeclined
            return
        }
        
        guard let token = authManager.authToken, !token.isEmpty else {
            syncState = .localOnly
            return
        }
        
        // 2. Identify newly recorded local sessions not yet synced
        let allMotor = motorStore.records
        let allWellness = wellnessStore.records
        
        let unsyncedMotor = allMotor.filter { !syncedMotorIds.contains($0.id.uuidString) }
        let unsyncedWellness = allWellness.filter { !syncedWellnessIds.contains($0.id.uuidString) }
        
        if unsyncedMotor.isEmpty && unsyncedWellness.isEmpty {
            syncState = .idle
            return
        }
        
        syncState = .syncing
        lastSyncError = nil
        
        let isoFormatter = ISO8601DateFormatter()
        
        let motorDTOs: [MotorSessionSyncItemDTO] = unsyncedMotor.map { record in
            let testTypeStr: String = (record.testType == .tapping) ? "tapping" : "spiral"
            let totalTaps: Int? = record.totalAttempts ?? (record.testType == .tapping ? Int(record.primaryScoreValue) : nil)
            let cadence: Double? = (record.testType == .tapping && record.durationSeconds > 0)
                ? (Double(totalTaps ?? 0) / record.durationSeconds)
                : nil
            
            return MotorSessionSyncItemDTO(
                localId: record.id.uuidString,
                testType: testTypeStr,
                startedAt: nil,
                completedAt: isoFormatter.string(from: record.date),
                durationSeconds: record.durationSeconds,
                cadenceTapsPerSec: cadence,
                intervalCv: nil,
                meanInterTapIntervalMs: nil,
                meanCenterDeviation: record.meanCenterDeviationPoints,
                meanAccuracyScore: record.alternationAccuracyPercent,
                totalTaps: totalTaps,
                spiralRmse: (record.testType == .spiral) ? record.primaryScoreValue : nil,
                spiralCompletionTimeSec: (record.testType == .spiral) ? record.durationSeconds : nil
            )
        }
        
        let wellnessDTOs: [WellnessSessionSyncItemDTO] = unsyncedWellness.map { record in
            let actTypeStr: String
            switch record.activityType {
            case .breathing: actTypeStr = "breathing"
            case .meditation: actTypeStr = "meditation"
            case .mindfulTracing: actTypeStr = "tracing"
            }
            
            return WellnessSessionSyncItemDTO(
                localId: record.id.uuidString,
                activityType: actTypeStr,
                startedAt: nil,
                completedAt: isoFormatter.string(from: record.date),
                durationSeconds: record.durationSeconds,
                cyclesCompleted: nil,
                targetCycles: nil,
                stressRating: record.ratingBefore,
                energyRating: nil,
                moodRating: record.ratingAfter
            )
        }
        
        let syncAccountID = authManager.currentUser?.id
        let batch = SyncBatchRequestDTO(motorSessions: motorDTOs, wellnessSessions: wellnessDTOs)
        
        do {
            let result = try await apiClient.syncSessions(token: token, batch: batch)
            
            // Guard against race conditions if user logged out or switched accounts during sync
            guard authManager.currentUser?.id == syncAccountID else {
                return
            }
            
            // Mark newly synced IDs locally
            var updatedMotorIds = syncedMotorIds
            for m in unsyncedMotor {
                updatedMotorIds.insert(m.id.uuidString)
            }
            syncedMotorIds = updatedMotorIds
            
            var updatedWellnessIds = syncedWellnessIds
            for w in unsyncedWellness {
                updatedWellnessIds.insert(w.id.uuidString)
            }
            syncedWellnessIds = updatedWellnessIds
            
            syncedCount += (result.syncedMotorCount + result.syncedWellnessCount)
            lastSyncDate = Date()
            syncState = .success
        } catch {
            lastSyncError = error.localizedDescription
            syncState = .failed
            // Local records remain safely on device!
        }
    }
    
    public func deleteRemoteData() async -> Bool {
        guard let token = authManager.authToken, !token.isEmpty else {
            return false
        }
        
        do {
            _ = try await apiClient.deleteRemoteData(token: token)
            // Clear synced IDs cache
            syncedMotorIds = []
            syncedWellnessIds = []
            // Mark consent as withdrawn locally
            _ = await consentManager.withdrawConsent(authToken: token)
            syncState = .consentDeclined
            return true
        } catch {
            lastSyncError = error.localizedDescription
            return false
        }
    }
    
    public func clearSyncCache() {
        syncedMotorIds = []
        syncedWellnessIds = []
        syncState = .idle
    }
}
