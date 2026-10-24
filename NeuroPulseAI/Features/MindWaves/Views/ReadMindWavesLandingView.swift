//
//  ReadMindWavesLandingView.swift
//  NeuroPulseAI
//
//  Dedicated landing page for the Read Mind Waves EEG experience.
//  Presents brain wave concepts, headset pairing visualization, and connection state.
//  Strictly UI-only in this phase without Bluetooth or hardware streaming.
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
            VStack(spacing: DesignTokens.Spacing.large) {
                // MARK: - Hero Visual with Ambient Wave Rings
                heroVisualSection

                // MARK: - Title & Exploration Scope
                VStack(spacing: DesignTokens.Spacing.small) {
                    Text("Explore Your Brain Activity")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)

                    Text("Connect a compatible EEG headset to begin reading your brain wave activity.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignTokens.Spacing.medium)
                }

                // MARK: - Connect Action Button
                connectActionButton

                // MARK: - Connection Status Banner
                connectionStatusCard

                // MARK: - Brain Wave Bands Overview
                brainWaveBandsSection
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.top, DesignTokens.Spacing.medium)
            .padding(.bottom, DesignTokens.Spacing.xxLarge)
        }
        .background(Color.NeuroPulse.surfaceBackground.ignoresSafeArea())
        .navigationTitle("Read Mind Waves")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    private var heroVisualSection: some View {
        ZStack {
            // Outer ambient pulse ring
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.NeuroPulse.brandTeal.opacity(0.12), Color.NeuroPulse.mindEaseSecondary.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 140, height: 140)

            // Middle ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.NeuroPulse.brandTeal.opacity(0.35), Color.NeuroPulse.mindEaseSecondary.opacity(0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: 110, height: 110)

            // Center emblem
            ZStack {
                Circle()
                    .fill(
                    LinearGradient(
                        colors: [Color.NeuroPulse.brandTeal, Color.NeuroPulse.mindEaseSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .shadow(color: Color.NeuroPulse.brandTeal.opacity(0.35), radius: 10, y: 5)

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.vertical, DesignTokens.Spacing.small)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Brain wave headset illustration")
    }

    private var connectActionButton: some View {
        Button {
            triggerConnectionCheck()
        } label: {
            HStack(spacing: DesignTokens.Spacing.small) {
                if isConnectingAttempt {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "wave.3.forward.circle.fill")
                        .font(.system(size: 20))
                }

                Text("Connect EEG Headset")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                LinearGradient(
                    colors: [Color.NeuroPulse.brandTeal, Color.NeuroPulse.mindEaseSecondary],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
            .shadow(color: Color.NeuroPulse.brandTeal.opacity(0.25), radius: 6, y: 3)
        }
        .disabled(isConnectingAttempt)
        .accessibilityLabel("Connect EEG Headset")
    }

    private var connectionStatusCard: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            HStack(spacing: DesignTokens.Spacing.small) {
                Image(systemName: connectionState.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(connectionState == .headsetNotConnected ? Color.NeuroPulse.warning : Color.NeuroPulse.error)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Connection Status")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)

                    Text(connectionState.statusBadgeText)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(connectionState == .headsetNotConnected ? Color.NeuroPulse.warning : .primary)
                }

                Spacer()

                // Status indicator pill
                HStack(spacing: 4) {
                    Circle()
                        .fill(connectionState == .headsetNotConnected ? Color.NeuroPulse.warning : Color.NeuroPulse.error)
                        .frame(width: 8, height: 8)
                    Text(connectionState == .headsetNotConnected ? "Scanned" : "Standby")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.NeuroPulse.surfaceBackground)
                .clipShape(Capsule())
            }

            Text(connectionState.statusMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.NeuroPulse.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    connectionState == .headsetNotConnected
                        ? Color.NeuroPulse.warning.opacity(0.35)
                        : Color.NeuroPulse.subtleBorder,
                    lineWidth: 0.75
                )
        )
    }

    private var brainWaveBandsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
            HStack {
                Text("Brain Wave Frequencies")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Spacer()
                Text("EEG Bands")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: DesignTokens.Spacing.small) {
                frequencyRow(
                    name: "Alpha",
                    range: "8 – 12 Hz",
                    state: "Calm Focus",
                    color: Color.NeuroPulse.brandTeal
                )

                frequencyRow(
                    name: "Beta",
                    range: "13 – 30 Hz",
                    state: "Concentration",
                    color: Color.NeuroPulse.motorPrimary
                )

                frequencyRow(
                    name: "Theta",
                    range: "4 – 8 Hz",
                    state: "Deep Relaxation",
                    color: Color.NeuroPulse.mindEaseSecondary
                )

                frequencyRow(
                    name: "Delta",
                    range: "0.5 – 4 Hz",
                    state: "Restorative",
                    color: Color.NeuroPulse.mindEasePrimary
                )
            }
        }
        .padding(16)
        .background(Color.NeuroPulse.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
        )
    }

    private func frequencyRow(name: String, range: String, state: String, color: Color) -> some View {
        HStack(spacing: DesignTokens.Spacing.small) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(name)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)

            Text("(\(range))")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Text(state)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(color)
        }
        .padding(.vertical, 4)
    }

    private func triggerConnectionCheck() {
        isConnectingAttempt = true
        // Brief simulated UI feedback without attempting any Bluetooth or hardware scanning
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            connectionState = .headsetNotConnected
            isConnectingAttempt = false
        }
    }
}
