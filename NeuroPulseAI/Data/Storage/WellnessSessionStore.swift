//
//  WellnessSessionStore.swift
//  NeuroPulseAI
//
//  Hardened local file-based persistence for MindEase wellness sessions.
//  Implements account-scoped data isolation, deterministic newest-first sorting,
//  isolated from motor data, with support for injectable testing directories.
//

import Foundation
import Combine

@MainActor
public final class WellnessSessionStore: ObservableObject {
    public static let shared = WellnessSessionStore()
    
    /// The visible records for the currently active account (or local/legacy if nil).
    @Published public private(set) var records: [WellnessSessionRecord] = []
    @Published public var lastErrorMessage: String? = nil
    
    public private(set) var activeAccountID: String? = nil
    
    /// All wellness records loaded from disk across accounts.
    private var allPersistedRecords: [WellnessSessionRecord] = []
    
    private let fileName = "wellness_sessions.json"
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
    public func records(for accountID: String?) -> [WellnessSessionRecord] {
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
    public func save(record: WellnessSessionRecord) {
        let targetAccount = record.accountID ?? activeAccountID
        let recordToSave: WellnessSessionRecord
        if record.accountID == targetAccount {
            recordToSave = record
        } else {
            recordToSave = WellnessSessionRecord(
                id: record.id,
                accountID: targetAccount,
                date: record.date,
                activityType: record.activityType,
                durationSeconds: record.durationSeconds,
                completionStatus: record.completionStatus,
                ratingBefore: record.ratingBefore,
                ratingAfter: record.ratingAfter
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
    
    /// Clear all records belonging to the active account only.
    public func clearAll() {
        if let active = activeAccountID {
            allPersistedRecords.removeAll { $0.accountID == active }
        } else {
            allPersistedRecords.removeAll { $0.accountID == nil }
        }
        persist()
        updateVisibleRecords()
    }
    
    public func persist() {
        do {
            let data = try JSONEncoder().encode(allPersistedRecords)
            try data.write(to: fileURL, options: [.atomic])
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = "Failed to persist wellness sessions: \(error.localizedDescription)"
            print("WellnessSessionStore persist error: \(error)")
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
            allPersistedRecords = try JSONDecoder().decode([WellnessSessionRecord].self, from: data)
            sortRecordsDescending(&allPersistedRecords)
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = "Failed to load wellness sessions. Previous data preserved."
            print("WellnessSessionStore load error: \(error)")
        }
        updateVisibleRecords()
    }
    
    private func updateVisibleRecords() {
        records = records(for: activeAccountID)
    }
    
    private func sortRecordsDescending(_ list: inout [WellnessSessionRecord]) {
        list.sort {
            if $0.date != $1.date {
                return $0.date > $1.date // Newest first
            }
            return $0.id.uuidString > $1.id.uuidString // Deterministic tie-breaker
        }
    }
}
