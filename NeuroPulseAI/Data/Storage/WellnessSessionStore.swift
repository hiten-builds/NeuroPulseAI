//
//  WellnessSessionStore.swift
//  NeuroPulseAI
//
//  Hardened local file-based persistence for MindEase wellness sessions,
//  isolated from motor data, with support for injectable testing directories.
//

import Foundation
import Combine

@MainActor
public final class WellnessSessionStore: ObservableObject {
    public static let shared = WellnessSessionStore()
    
    @Published public private(set) var records: [WellnessSessionRecord] = []
    @Published public var lastErrorMessage: String? = nil
    
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
    
    public func save(record: WellnessSessionRecord) {
        records.insert(record, at: 0)
        persist()
    }
    
    public func clearAll() {
        records.removeAll()
        persist()
    }
    
    public func persist() {
        do {
            let data = try JSONEncoder().encode(records)
            try data.write(to: fileURL, options: [.atomic])
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = "Failed to persist wellness sessions: \(error.localizedDescription)"
            print("WellnessSessionStore persist error: \(error)")
        }
    }
    
    public func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            records = try JSONDecoder().decode([WellnessSessionRecord].self, from: data)
            records.sort(by: { $0.date > $1.date })
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = "Failed to load wellness sessions. Previous data preserved."
            print("WellnessSessionStore load error: \(error)")
        }
    }
}
