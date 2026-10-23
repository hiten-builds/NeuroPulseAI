//
//  SessionExportServiceTests.swift
//  NeuroPulseAITests
//
//  Unit tests verifying CSV export formatting, delimiter escaping, and formula injection protection.
//

import XCTest
@testable import NeuroPulseAI

final class SessionExportServiceTests: XCTestCase {
    
    func testCSVHeaderAndRecordFormatting() {
        let records = [
            MotorSessionRecord(
                testType: .tapping,
                testedHand: "Right",
                durationSeconds: 15.0,
                primaryScoreLabel: "5.8 Hz",
                primaryScoreValue: 5.8,
                secondaryScoreLabel: "87 taps",
                qualityStatus: .valid,
                protocolVersion: "2.0",
                isSampleData: false,
                meanCenterDeviationPoints: 4.5,
                meanNormalizedCenterDeviationPercent: 14.06,
                alternationAccuracyPercent: 98.0
            )
        ]
        
        let csv = SessionExportService.generateCSV(from: records)
        let lines = csv.components(separatedBy: "\r\n")
        
        XCTAssertGreaterThanOrEqual(lines.count, 2)
        XCTAssertTrue(lines[0].contains("Session ID,Date,ISO Timestamp,Test Type"))
        XCTAssertTrue(lines[0].contains("Mean Deviation Points,Normalized Deviation Percent,Alternation Accuracy Percent"))
        XCTAssertTrue(lines[1].contains("Finger Tapping,Right,15.00,5.8 Hz,5.8000,87 taps,Valid Session,4.50,14.06,98.00,2.0,FALSE"))
    }
    
    func testFormulaInjectionMitigation() {
        // Values starting with =, +, -, @ must be prefixed with single quote
        let dangerousField = "=cmd|' /C calc'!A0"
        let sanitized = SessionExportService.sanitizeField(dangerousField)
        XCTAssertTrue(sanitized.hasPrefix("'="))
        
        let safeField = "Regular Label"
        XCTAssertEqual(SessionExportService.sanitizeField(safeField), "Regular Label")
    }
    
    func testDelimiterAndQuoteEscaping() {
        // Values containing commas and quotes must be wrapped and quotes doubled
        let fieldWithComma = "Taps, accepted"
        XCTAssertEqual(SessionExportService.sanitizeField(fieldWithComma), "\"Taps, accepted\"")
        
        let fieldWithQuote = "Protocol \"v1\""
        XCTAssertEqual(SessionExportService.sanitizeField(fieldWithQuote), "\"Protocol \"\"v1\"\"\"")
    }
}
