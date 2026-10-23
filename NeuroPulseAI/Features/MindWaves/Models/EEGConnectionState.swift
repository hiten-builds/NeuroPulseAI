//
//  EEGConnectionState.swift
//  NeuroPulseAI
//
//  UI-only state model for the Read Mind Waves EEG connection experience.
//  Extensible architecture designed to support future hardware scanning and streaming.
//

import Foundation

public enum EEGConnectionState: Equatable, Sendable {
    case notConnected
    case headsetNotConnected

    public var statusBadgeText: String {
        switch self {
        case .notConnected:
            return "Not Connected"
        case .headsetNotConnected:
            return "Headset Not Connected"
        }
    }

    public var statusMessage: String {
        switch self {
        case .notConnected:
            return "No compatible EEG headset is currently connected to this device."
        case .headsetNotConnected:
            return "No compatible EEG headset was detected. Ensure your headset is powered on and in pairing mode."
        }
    }

    public var iconName: String {
        switch self {
        case .notConnected:
            return "antenna.radiowaves.left.and.right.slash"
        case .headsetNotConnected:
            return "exclamationmark.triangle.fill"
        }
    }
}
