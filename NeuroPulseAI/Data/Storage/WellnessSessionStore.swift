//
//  WellnessSessionStore.swift
//  NeuroPulseAI
//
//  Local file-based persistence for MindEase wellness sessions, isolated from motor data.
//

import Foundation
import Combine

@MainActor
public final class WellnessSessionStore: ObservableObject {
    public static let shared = WellnessSessionStore()
    
    @Published public private(set) var records: [WellnessSessionRecord] = []
    
    private let fileName = "wellness_sessions.json"
    
    public init() {
        load()
    }
    
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let dir = paths[0].appendingPathComponent("NeuroPulseAI", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent(fileName)
    }
    
    public func save(record: WellnessSessionRecord) {
        records.insert(record, at: 0)
        persist()
    }
    
    public func clearAll() {
        records.removeAll()
        persist()
    }
    
    private func persist() {
        do {
            let data = try JSONEncoder().encode(records)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("Failed to persist wellness sessions: \(error)")
        }
    }
    
    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            records = try JSONDecoder().decode([WellnessSessionRecord].self, from: data)
            records.sort(by: { $0.date > $1.date })
        } catch {
            print("Failed to load wellness sessions: \(error)")
        }
    }
}
