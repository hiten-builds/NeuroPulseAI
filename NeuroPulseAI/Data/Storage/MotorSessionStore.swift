//
//  MotorSessionStore.swift
//  NeuroPulseAI
//
//  Hardened local file-based persistence for motor assessment sessions.
//  Uses atomic writes, isolated Application Support directory, and supports
//  dependency-injected storage directories for isolated unit tests.
//

import Foundation
import Combine

@MainActor
public final class MotorSessionStore: ObservableObject {
    public static let shared = MotorSessionStore()
    
    @Published public private(set) var records: [MotorSessionRecord] = []
    @Published public var lastErrorMessage: String? = nil
    
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
    
    public func save(record: MotorSessionRecord) {
        records.insert(record, at: 0)
        persist()
    }
    
    public func delete(id: UUID) {
        records.removeAll { $0.id == id }
        persist()
    }
    
    public func clearAll() {
        records.removeAll()
        persist()
    }
    
    public func loadSampleDemonstrationData() {
        let calendar = Calendar.current
        let now = Date()
        
        let samples: [MotorSessionRecord] = [
            MotorSessionRecord(
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
        
        // Add only if not already containing records
        for s in samples {
            if !records.contains(where: { $0.id == s.id }) {
                records.append(s)
            }
        }
        records.sort(by: { $0.date > $1.date })
        persist()
    }
    
    public func persist() {
        do {
            let data = try JSONEncoder().encode(records)
            try data.write(to: fileURL, options: [.atomic])
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = "Failed to save sessions: \(error.localizedDescription)"
            print("MotorSessionStore persist error: \(error)")
        }
    }
    
    public func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return
        }
        do {
            let data = try Data(contentsOf: fileURL)
            records = try JSONDecoder().decode([MotorSessionRecord].self, from: data)
            records.sort(by: { $0.date > $1.date })
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = "Failed to load saved sessions. Previous data preserved."
            print("MotorSessionStore load error: \(error)")
        }
    }
}
