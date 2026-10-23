//
//  MotorSessionStore.swift
//  NeuroPulseAI
//
//  Hardened local file-based persistence for motor assessment sessions.
//  Implements account-scoped data isolation, deterministic newest-first sorting,
//  atomic writes, and isolated Application Support directory.
//

import Foundation
import Combine

@MainActor
public final class MotorSessionStore: ObservableObject {
    public static let shared = MotorSessionStore()
    
    /// The visible records for the currently active account (or local/legacy if nil).
    @Published public private(set) var records: [MotorSessionRecord] = []
    @Published public var lastErrorMessage: String? = nil
    
    public private(set) var activeAccountID: String? = nil
    
    /// All records loaded from disk across accounts.
    private var allPersistedRecords: [MotorSessionRecord] = []
    
    private let fileName = "motor_sessions.json"
    private let customDirectory: URL?
    
    public init(customDirectory: URL? = nil) {
        self.customDirectory = customDirectory
        load()
    }
    
    public var fileURL: URL {
        let dir: URL
        if let custom = customDirectory {
            dir = custom
        } else {
            let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            dir = paths[0].appendingPathComponent("NeuroPulseAI", isDirectory: true)
        }
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent(fileName)
    }
    
    /// Switches the active account and updates the visible in-memory records.
    public func reload(for accountID: String?) {
        self.activeAccountID = accountID
        updateVisibleRecords()
    }
    
    /// Query records for a specific account (or local/legacy if nil), deterministically sorted newest-first.
    public func records(for accountID: String?) -> [MotorSessionRecord] {
        var filtered = allPersistedRecords.filter { record in
            if let target = accountID {
                return record.accountID == target
            } else {
                return record.accountID == nil
            }
        }
        sortRecordsDescending(&filtered)
        return filtered
    }
    
    /// Save a record with guaranteed ownership attachment, deterministic sorting, and atomic persistence.
    public func save(record: MotorSessionRecord) {
        // Guarantee account ownership is attached if not already set
        let targetAccount = record.accountID ?? activeAccountID
        let recordToSave: MotorSessionRecord
        if record.accountID == targetAccount {
            recordToSave = record
        } else {
            recordToSave = MotorSessionRecord(
                id: record.id,
                accountID: targetAccount,
                date: record.date,
                testType: record.testType,
                testedHand: record.testedHand,
                durationSeconds: record.durationSeconds,
                primaryScoreLabel: record.primaryScoreLabel,
                primaryScoreValue: record.primaryScoreValue,
                secondaryScoreLabel: record.secondaryScoreLabel,
                qualityStatus: record.qualityStatus,
                protocolVersion: record.protocolVersion,
                isSampleData: record.isSampleData,
                completionStatus: record.completionStatus,
                meanCenterDeviationPoints: record.meanCenterDeviationPoints,
                meanNormalizedCenterDeviationPercent: record.meanNormalizedCenterDeviationPercent,
                totalAttempts: record.totalAttempts,
                correctAlternatingTaps: record.correctAlternatingTaps,
                alternationAccuracyPercent: record.alternationAccuracyPercent
            )
        }
        
        allPersistedRecords.append(recordToSave)
        sortRecordsDescending(&allPersistedRecords)
        persist()
        updateVisibleRecords()
    }
    
    public func delete(id: UUID) {
        allPersistedRecords.removeAll { $0.id == id }
        persist()
        updateVisibleRecords()
    }
    
    /// Clear all records belonging to the active account only (does NOT wipe other accounts).
    public func clearAll() {
        if let active = activeAccountID {
            allPersistedRecords.removeAll { $0.accountID == active }
        } else {
            allPersistedRecords.removeAll { $0.accountID == nil }
        }
        persist()
        updateVisibleRecords()
    }
    
    public func loadSampleDemonstrationData() {
        let calendar = Calendar.current
        let now = Date()
        
        let samples: [MotorSessionRecord] = [
            MotorSessionRecord(
                accountID: activeAccountID,
                date: calendar.date(byAdding: .day, value: -6, to: now) ?? now,
                testType: .tapping,
                testedHand: "Right",
                durationSeconds: 15.0,
                primaryScoreLabel: "5.4 Hz",
                primaryScoreValue: 5.4,
                secondaryScoreLabel: "81 taps",
                qualityStatus: .valid,
                isSampleData: true
            ),
            MotorSessionRecord(
                accountID: activeAccountID,
                date: calendar.date(byAdding: .day, value: -4, to: now) ?? now,
                testType: .tapping,
                testedHand: "Right",
                durationSeconds: 15.0,
                primaryScoreLabel: "5.7 Hz",
                primaryScoreValue: 5.7,
                secondaryScoreLabel: "85 taps",
                qualityStatus: .valid,
                isSampleData: true
            ),
            MotorSessionRecord(
                accountID: activeAccountID,
                date: calendar.date(byAdding: .day, value: -2, to: now) ?? now,
                testType: .tapping,
                testedHand: "Right",
                durationSeconds: 15.0,
                primaryScoreLabel: "6.1 Hz",
                primaryScoreValue: 6.1,
                secondaryScoreLabel: "91 taps",
                qualityStatus: .valid,
                isSampleData: true
            ),
            MotorSessionRecord(
                accountID: activeAccountID,
                date: calendar.date(byAdding: .day, value: -5, to: now) ?? now,
                testType: .spiral,
                testedHand: "Right",
                durationSeconds: 14.2,
                primaryScoreLabel: "7.8% RMSE",
                primaryScoreValue: 7.8,
                secondaryScoreLabel: "1.08x length",
                qualityStatus: .valid,
                isSampleData: true
            ),
            MotorSessionRecord(
                accountID: activeAccountID,
                date: calendar.date(byAdding: .day, value: -3, to: now) ?? now,
                testType: .spiral,
                testedHand: "Right",
                durationSeconds: 12.8,
                primaryScoreLabel: "6.2% RMSE",
                primaryScoreValue: 6.2,
                secondaryScoreLabel: "1.04x length",
                qualityStatus: .valid,
                isSampleData: true
            ),
            MotorSessionRecord(
                accountID: activeAccountID,
                date: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
                testType: .spiral,
                testedHand: "Right",
                durationSeconds: 11.9,
                primaryScoreLabel: "5.1% RMSE",
                primaryScoreValue: 5.1,
                secondaryScoreLabel: "1.02x length",
                qualityStatus: .valid,
                isSampleData: true
            )
        ]
        
        for s in samples {
            if !allPersistedRecords.contains(where: { $0.id == s.id }) {
                allPersistedRecords.append(s)
            }
        }
        sortRecordsDescending(&allPersistedRecords)
        persist()
        updateVisibleRecords()
    }
    
    public func persist() {
        do {
            let data = try JSONEncoder().encode(allPersistedRecords)
            try data.write(to: fileURL, options: [.atomic])
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = "Failed to save sessions: \(error.localizedDescription)"
            print("MotorSessionStore persist error: \(error)")
        }
    }
    
    public func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            allPersistedRecords = []
            updateVisibleRecords()
            return
        }
        do {
            let data = try Data(contentsOf: fileURL)
            allPersistedRecords = try JSONDecoder().decode([MotorSessionRecord].self, from: data)
            sortRecordsDescending(&allPersistedRecords)
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = "Failed to load saved sessions. Previous data preserved."
            print("MotorSessionStore load error: \(error)")
        }
        updateVisibleRecords()
    }
    
    private func updateVisibleRecords() {
        records = records(for: activeAccountID)
    }
    
    private func sortRecordsDescending(_ list: inout [MotorSessionRecord]) {
        list.sort {
            if $0.date != $1.date {
                return $0.date > $1.date // Newest first
            }
            return $0.id.uuidString > $1.id.uuidString // Deterministic tie-breaker
        }
    }
}
