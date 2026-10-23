//
//  SessionExportService.swift
//  NeuroPulseAI
//
//  User-initiated CSV export utility for motor assessment session records.
//  Implements RFC 4180 escaping, formula injection protection, and exports
//  fine-motor metrics including two-zone center deviation accuracy.
//

import Foundation

public struct SessionExportService {
    /// Generates compliant CSV content from motor session records.
    public static func generateCSV(from records: [MotorSessionRecord]) -> String {
        var lines: [String] = []
        
        // CSV Header
        lines.append("Session ID,Date,ISO Timestamp,Test Type,Tested Hand,Duration Seconds,Primary Metric,Primary Value,Secondary Metric,Quality Status,Mean Deviation Points,Normalized Deviation Percent,Alternation Accuracy Percent,Protocol Version,Is Sample Data")
        
        let isoFormatter = ISO8601DateFormatter()
        
        for record in records {
            let meanDevStr = record.meanCenterDeviationPoints != nil ? String(format: "%.2f", record.meanCenterDeviationPoints!) : ""
            let normDevStr = record.meanNormalizedCenterDeviationPercent != nil ? String(format: "%.2f", record.meanNormalizedCenterDeviationPercent!) : ""
            let accStr = record.alternationAccuracyPercent != nil ? String(format: "%.2f", record.alternationAccuracyPercent!) : ""
            
            let fields: [String] = [
                sanitizeField(record.id.uuidString),
                sanitizeField(record.date.formatted(date: .abbreviated, time: .shortened)),
                sanitizeField(isoFormatter.string(from: record.date)),
                sanitizeField(record.testType.rawValue),
                sanitizeField(record.testedHand),
                String(format: "%.2f", record.durationSeconds),
                sanitizeField(record.primaryScoreLabel),
                String(format: "%.4f", record.primaryScoreValue),
                sanitizeField(record.secondaryScoreLabel),
                sanitizeField(record.qualityStatus.rawValue),
                meanDevStr,
                normDevStr,
                accStr,
                sanitizeField(record.protocolVersion),
                record.isSampleData ? "TRUE" : "FALSE"
            ]
            lines.append(fields.joined(separator: ","))
        }
        
        return lines.joined(separator: "\r\n")
    }
    
    /// Sanitizes and escapes fields against formula injection and delimiters.
    public static func sanitizeField(_ value: String) -> String {
        var sanitized = value
        
        // Formula injection mitigation (prevent execution if opened in Excel/Sheets)
        if let first = sanitized.first, ["=", "+", "-", "@", "\t", "\r"].contains(first) {
            sanitized = "'" + sanitized
        }
        
        // Escape quotes and wrap in quotes if field contains commas, quotes, or newlines
        if sanitized.contains(",") || sanitized.contains("\"") || sanitized.contains("\n") || sanitized.contains("\r") {
            let escaped = sanitized.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        
        return sanitized
    }
    
    /// Writes CSV data to a temporary file URL suitable for native UI share sheet.
    public static func exportTemporaryCSVFile(from records: [MotorSessionRecord]) -> URL? {
        let csvText = generateCSV(from: records)
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("NeuroPulseAI_Motor_Sessions.csv")
        
        do {
            try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Failed to write temporary CSV file: \(error)")
            return nil
        }
    }
}
