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

                // MARK: - How It Works Informational Card
                howItWorksSection

                // MARK: - Non-Diagnostic Disclaimer
                disclaimerNotice
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
                    .fontWeight(.semibold)
            }
            .font(.body)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: [Color.NeuroPulse.brandTeal, Color.NeuroPulse.mindEaseSecondary],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
            .shadow(color: Color.NeuroPulse.brandTeal.opacity(0.3), radius: 8, y: 4)
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
                        .font(.caption2)
                        .fontWeight(.bold)
                        .textCase(.uppercase)
                        .tracking(1.0)
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
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, DesignTokens.Spacing.small)
                .padding(.vertical, 4)
                .background(Color.NeuroPulse.surfaceBackground)
                .clipShape(Capsule())
            }

            Text(connectionState.statusMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)
        }
        .padding(DesignTokens.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.NeuroPulse.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                .stroke(
                    connectionState == .headsetNotConnected
                        ? Color.NeuroPulse.warning.opacity(0.3)
                        : Color.NeuroPulse.subtleBorder,
                    lineWidth: 1
                )
        )
    }

    private var brainWaveBandsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
            HStack {
                Text("BRAIN WAVE FREQUENCIES")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .tracking(1.2)
                    .foregroundStyle(Color.NeuroPulse.brandTeal)
                Spacer()
                Text("EEG Overview")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: DesignTokens.Spacing.small) {
                frequencyRow(
                    name: "Alpha",
                    range: "8 – 12 Hz",
                    state: "Calm Focus & Alertness",
                    description: "Predominates during relaxed wakefulness, meditation, and mindful pausing.",
                    color: Color.NeuroPulse.brandTeal
                )

                frequencyRow(
                    name: "Beta",
                    range: "13 – 30 Hz",
                    state: "Active Concentration",
                    description: "Associated with active problem solving, motor coordination, and alertness.",
                    color: Color.NeuroPulse.motorPrimary
                )

                frequencyRow(
                    name: "Theta",
                    range: "4 – 8 Hz",
                    state: "Deep Relaxation",
                    description: "Observed in twilight states, daydreaming, and deep mindful breathing.",
                    color: Color.NeuroPulse.mindEaseSecondary
                )

                frequencyRow(
                    name: "Delta",
                    range: "0.5 – 4 Hz",
                    state: "Restorative Rest",
                    description: "Slow-wave rhythmic activity during deep sleep and physical regeneration.",
                    color: Color.NeuroPulse.mindEasePrimary
                )
            }
        }
        .padding(DesignTokens.Spacing.medium)
        .background(Color.NeuroPulse.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
        )
    }

    private func frequencyRow(name: String, range: String, state: String, description: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.small) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Text("(\(range))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(state)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(color)
                }

                Text(description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 4)
    }

    private var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            Text("ABOUT THE EEG EXPERIENCE")
                .font(.caption2)
                .fontWeight(.bold)
                .tracking(1.2)
                .foregroundStyle(.secondary)

            HStack(alignment: .top, spacing: DesignTokens.Spacing.medium) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.NeuroPulse.brandTeal)
                    .frame(width: 32)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Non-Invasive Brain Wave Sensing")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text("Future phases will pair with lightweight consumer EEG headsets via low-energy Bluetooth to translate microvolt oscillatory rhythms into personal focus and calm indicators alongside your motor and wellness trends.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(DesignTokens.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.NeuroPulse.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
        )
    }

    private var disclaimerNotice: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.small) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)

            Text("Non-Diagnostic Informational Scope: NeuroPulseAI brain wave metrics and mind state tracking are designed solely for self-reflection and personal wellness. They do not constitute neurological diagnoses or clinical evaluations.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(DesignTokens.Spacing.medium)
        .background(Color.NeuroPulse.cardBackground.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.small))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.small)
                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
        )
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
