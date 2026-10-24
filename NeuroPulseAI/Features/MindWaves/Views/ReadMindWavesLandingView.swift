//
//  ReadMindWavesLandingView.swift
//  NeuroPulseAI
//
//  Dedicated landing page for the Read Mind Waves EEG experience in Soft Neo-Brutalist design:
//  Peach/lavender hero card, 2pt ink outlines, hard offset shadows (3, 3),
//  white outlined icon tile, tactile press button, and peach status badge.
//

import SwiftUI

public struct ReadMindWavesLandingView: View {
    @State private var connectionState: EEGConnectionState = .notConnected
    @State private var isConnectingAttempt: Bool = false

    public init() {
        _connectionState = State(initialValue: .notConnected)
    }

    public init(initialState: EEGConnectionState) {
        _connectionState = State(initialValue: initialState)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Peach Hero Card
                heroCardSection

                // MARK: - Connect Action Button (Tactile Brutal Style)
                connectActionButton

                // MARK: - Connection Status Card
                connectionStatusCard

                // MARK: - Brain Wave Bands Overview
                brainWaveBandsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 36)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("Read Mind Waves")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    private var heroCardSection: some View {
        VStack(spacing: 14) {
            // White outlined icon tile
            BrutalIconTile(
                iconName: "brain.head.profile",
                size: 64,
                iconSize: 32,
                cornerRadius: 18,
                outlineWidth: 2,
                bg: .white,
                iconColor: Color.NeoBrutal.ink
            )

            VStack(spacing: 6) {
                Text("Explore Your Brain Activity")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.NeoBrutal.ink)
                    .multilineTextAlignment(.center)

                Text("Connect a compatible EEG headset to begin reading your brain wave activity.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.NeoBrutal.ink.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .brutalCard(cornerRadius: 24, fill: Color.NeoBrutal.peach, outlineWidth: 2, hasShadow: true, shadowOffset: 3)
    }

    private var connectActionButton: some View {
        Button {
            triggerConnectionCheck()
        } label: {
            HStack(spacing: 8) {
                if isConnectingAttempt {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.NeoBrutal.ink))
                } else {
                    Image(systemName: "wave.3.forward.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                }

                Text("Connect EEG Headset")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
            }
        }
        .buttonStyle(BrutalButtonStyle(fill: Color.NeoBrutal.lavender, minHeight: 52))
        .disabled(isConnectingAttempt)
        .accessibilityLabel("Connect EEG Headset")
    }

    private var connectionStatusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                BrutalIconTile(
                    iconName: connectionState.iconName,
                    size: 40,
                    iconSize: 18,
                    cornerRadius: 12,
                    outlineWidth: 1.5,
                    bg: connectionState == .headsetNotConnected ? Color.NeoBrutal.peach : Color.white,
                    iconColor: Color.NeoBrutal.ink
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Connection Status")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.mutedText)

                    Text(connectionState.statusBadgeText)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.ink)
                }

                Spacer()

                // Peach status badge after Connect is tapped
                if connectionState == .headsetNotConnected {
                    BrutalBadge("Headset Not Connected", style: .custom(bg: Color.NeoBrutal.peach, fg: Color.NeoBrutal.ink))
                } else {
                    BrutalBadge("Standby", style: .complete)
                }
            }

            Text(connectionState.statusMessage)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.mutedText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .brutalCard(cornerRadius: 20, fill: .white, outlineWidth: 2, hasShadow: true, shadowOffset: 3)
    }

    private var brainWaveBandsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Brain Wave Frequencies")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.NeoBrutal.ink)
                Spacer()
                BrutalBadge("EEG Bands", style: .custom(bg: Color.NeoBrutal.pink, fg: Color.NeoBrutal.ink))
            }

            VStack(spacing: 8) {
                frequencyRow(
                    name: "Alpha",
                    range: "8 – 12 Hz",
                    state: "Calm Focus",
                    fillColor: Color.NeoBrutal.lavender
                )

                frequencyRow(
                    name: "Beta",
                    range: "13 – 30 Hz",
                    state: "Concentration",
                    fillColor: Color.NeoBrutal.mint
                )

                frequencyRow(
                    name: "Theta",
                    range: "4 – 8 Hz",
                    state: "Deep Relaxation",
                    fillColor: Color.NeoBrutal.peach
                )

                frequencyRow(
                    name: "Delta",
                    range: "0.5 – 4 Hz",
                    state: "Restorative",
                    fillColor: Color.NeoBrutal.pink
                )
            }
        }
        .padding(18)
        .brutalCard(cornerRadius: 20, fill: .white, outlineWidth: 2, hasShadow: true, shadowOffset: 3)
    }

    private func frequencyRow(name: String, range: String, state: String, fillColor: Color) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(fillColor)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(Color.NeoBrutal.ink, lineWidth: 1.5)
                )

            Text(name)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.ink)

            Text("(\(range))")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.mutedText)

            Spacer()

            BrutalBadge(state, style: .custom(bg: fillColor, fg: Color.NeoBrutal.ink))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .brutalRow(cornerRadius: 14, fill: .white, outlineWidth: 1.5)
    }

    private func triggerConnectionCheck() {
        isConnectingAttempt = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            connectionState = .headsetNotConnected
            isConnectingAttempt = false
        }
    }
}

#Preview {
    NavigationStack {
        ReadMindWavesLandingView()
    }
}
