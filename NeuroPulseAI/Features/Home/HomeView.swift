//
//  HomeView.swift
//  NeuroPulseAI
//
//  Main application dashboard in Soft Neo-Brutalist design language:
//  White surface, 2pt ink outlines (#0A0A0A), flat pastel fills
//  (Lavender #D4C6F7, Mint #D3F7B4, Peach #F8D89A), hard offset shadows (3, 3),
//  rounded-geometric sans typography (.fontDesign(.rounded)), and tactile press affordances.
//

import SwiftUI

public struct HomeView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @ObservedObject private var consentManager = ConsentManager.shared
    @State private var showingAccountSettings = false
    @State private var selectedFilterChip: String = "All Modes"

    private let filterChips = ["All Modes", "Motor Health", "MindEase", "Mind Waves", "Saved Records"]

    public init() {}

    private var userName: String {
        if authManager.currentMode == .authenticated, let email = authManager.currentUser?.email {
            let prefix = email.components(separatedBy: "@").first ?? "Friend"
            return prefix.prefix(1).uppercased() + prefix.dropFirst()
        }
        return "Friend"
    }

    private var isCloudPersonalized: Bool {
        authManager.currentMode == .authenticated && consentManager.isPersonalizationConsented
    }

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.white.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // 1. Header: Circular black logo mark + app name + avatar top-right
                        headerSection

                        // 2. Greeting: "Hello, {name}" + large "Good Morning!"
                        greetingSection

                        // 3. Horizontally scrolling outlined chips
                        chipFilterSection

                        // 4. Stack of 3 primary feature cards (Lavender, Mint, Peach)
                        primaryFeatureCardsSection

                        // 5. Secondary section: "Recents"-style card with Recommendations & Activity History
                        recentsSection

                        // 6. Account / status info: compact outlined row with status badge
                        accountStatusRow

                        // Spacer for bottom dock padding
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 48)
                }

                // 7. Bottom navigation dock: white, outlined, active tile = lavender + hard shadow
                bottomNavDock
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAccountSettings) {
                NavigationStack {
                    AccountSettingsView()
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("Done") {
                                    showingAccountSettings = false
                                }
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.NeoBrutal.ink)
                            }
                        }
                }
            }
        }
    }

    // MARK: - 1. Header Section
    private var headerSection: some View {
        HStack(alignment: .center, spacing: 12) {
            // Circular black logo mark
            ZStack {
                Circle()
                    .fill(Color.NeoBrutal.ink)
                    .frame(width: 40, height: 40)

                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)

            Text("NeuroPulse AI")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.ink)

            Spacer()

            // Avatar / Profile Button (top-right entry to Account & Privacy)
            Button {
                showingAccountSettings = true
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.NeoBrutal.ink)
                        .offset(x: 2, y: 2)
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white)
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.NeoBrutal.ink, lineWidth: 2)

                    Image(systemName: authManager.currentMode == .authenticated ? "person.crop.circle.fill" : "person.crop.circle")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.NeoBrutal.ink)
                }
                .frame(width: 40, height: 40)
            }
            .accessibilityLabel("Account and Privacy Settings")
        }
        .padding(.top, 4)
    }

    // MARK: - 2. Greeting Section
    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Hello, \(userName)")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.mutedText)

            Text("Good Morning!")
                .font(.system(size: 36, weight: .medium, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.ink)
        }
    }

    // MARK: - 3. Horizontally Scrolling Outlined Chips Row
    private var chipFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(filterChips, id: \.self) { chip in
                    let isActive = selectedFilterChip == chip
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilterChip = chip
                        }
                    } label: {
                        Text(chip)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.NeoBrutal.ink)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 9)
                            .background(
                                ZStack {
                                    Capsule()
                                        .fill(Color.NeoBrutal.ink)
                                        .offset(x: 2.5, y: 2.5)
                                    Capsule()
                                        .fill(isActive ? Color.NeoBrutal.lavender : Color.white)
                                    Capsule()
                                        .stroke(Color.NeoBrutal.ink, lineWidth: 2)
                                }
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.vertical, 4)
            .padding(.trailing, 4)
        }
    }

    // MARK: - 4. Primary Feature Cards (Lavender, Mint, Peach)
    private var primaryFeatureCardsSection: some View {
        VStack(spacing: 16) {
            if selectedFilterChip == "All Modes" || selectedFilterChip == "Motor Health" {
                NavigationLink {
                    MotorHealthHomeView()
                } label: {
                    ModeCardView(
                        title: "Motor Health",
                        subtitle: "Fine-motor dexterity and rhythm consistency",
                        meta: "2 tests · ~5 min",
                        iconName: "hand.tap.fill",
                        fill: Color.NeoBrutal.lavender
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }

            if selectedFilterChip == "All Modes" || selectedFilterChip == "MindEase" {
                NavigationLink {
                    MindEaseHomeView()
                } label: {
                    ModeCardView(
                        title: "MindEase",
                        subtitle: "Paced breathing and mindful stillness",
                        meta: "3 exercises · Calming",
                        iconName: "wind",
                        fill: Color.NeoBrutal.mint
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }

            if selectedFilterChip == "All Modes" || selectedFilterChip == "Mind Waves" {
                NavigationLink {
                    ReadMindWavesLandingView()
                } label: {
                    ModeCardView(
                        title: "Read Mind Waves",
                        subtitle: "Real-time brain wave rhythm visualization",
                        meta: "EEG headset · Real-time",
                        iconName: "waveform.path.ecg",
                        fill: Color.NeoBrutal.peach
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }

            if selectedFilterChip == "Saved Records" {
                NavigationLink {
                    SavedRecordsView()
                } label: {
                    ModeCardView(
                        title: "Saved Assessment Records",
                        subtitle: "Review historical motor and wellness logs",
                        meta: "Activity history · Exportable",
                        iconName: "clock.arrow.circlepath",
                        fill: Color.NeoBrutal.pink
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    // MARK: - 5. Secondary "Recents" Card
    private var recentsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Activity & Insights")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.ink)

            VStack(spacing: 10) {
                // Recommendations Row
                NavigationLink {
                    RecommendationsView()
                } label: {
                    HStack(spacing: 12) {
                        BrutalIconTile(
                            iconName: "sparkles",
                            size: 42,
                            iconSize: 18,
                            cornerRadius: 12,
                            outlineWidth: 1.5,
                            bg: Color.NeoBrutal.lavender.opacity(0.35)
                        )

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Recommendations")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.NeoBrutal.ink)

                            Text("Personalized guidance & trends")
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundStyle(Color.NeoBrutal.mutedText)
                        }

                        Spacer()

                        BrutalBadge(
                            isCloudPersonalized ? "Cloud" : "Local",
                            style: isCloudPersonalized ? .inProgress : .pending
                        )

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.NeoBrutal.ink)
                    }
                    .padding(14)
                    .brutalRow(cornerRadius: 16, fill: .white, outlineWidth: 1.5)
                }
                .buttonStyle(PlainButtonStyle())

                // Activity History Row
                NavigationLink {
                    SavedRecordsView()
                } label: {
                    HStack(spacing: 12) {
                        BrutalIconTile(
                            iconName: "clock.arrow.circlepath",
                            size: 42,
                            iconSize: 18,
                            cornerRadius: 12,
                            outlineWidth: 1.5,
                            bg: Color.NeoBrutal.mint.opacity(0.35)
                        )

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Activity History")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.NeoBrutal.ink)

                            Text("Review completed sessions")
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundStyle(Color.NeoBrutal.mutedText)
                        }

                        Spacer()

                        BrutalBadge("History", style: .complete)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.NeoBrutal.ink)
                    }
                    .padding(14)
                    .brutalRow(cornerRadius: 16, fill: .white, outlineWidth: 1.5)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(18)
        .brutalCard(cornerRadius: 24, fill: .white, outlineWidth: 2, hasShadow: true, shadowOffset: 3)
    }

    // MARK: - 6. Compact Account / Privacy Status Row
    private var accountStatusRow: some View {
        HStack(spacing: 10) {
            Image(systemName: isCloudPersonalized ? "cloud.shield.fill" : "lock.shield.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.NeoBrutal.ink)

            Text(statusTitle)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.ink)

            Spacer()

            BrutalBadge(
                statusSubtitle,
                style: isCloudPersonalized ? .inProgress : .pending
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .brutalRow(cornerRadius: 16, fill: .white, outlineWidth: 1.5)
    }

    // MARK: - 7. Bottom Navigation Dock
    private var bottomNavDock: some View {
        HStack(spacing: 10) {
            // Home (Active)
            dockTile(title: "Home", icon: "house.fill", isActive: true)

            // Motor Health
            NavigationLink {
                MotorHealthHomeView()
            } label: {
                dockTile(title: "Motor", icon: "hand.tap.fill", isActive: false)
            }
            .buttonStyle(PlainButtonStyle())

            // MindEase
            NavigationLink {
                MindEaseHomeView()
            } label: {
                dockTile(title: "MindEase", icon: "wind", isActive: false)
            }
            .buttonStyle(PlainButtonStyle())

            // Mind Waves
            NavigationLink {
                ReadMindWavesLandingView()
            } label: {
                dockTile(title: "Waves", icon: "waveform.path.ecg", isActive: false)
            }
            .buttonStyle(PlainButtonStyle())

            // History / Records
            NavigationLink {
                SavedRecordsView()
            } label: {
                dockTile(title: "History", icon: "clock.arrow.circlepath", isActive: false)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.NeoBrutal.ink)
                    .offset(x: 3, y: 3)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.NeoBrutal.ink, lineWidth: 2)
            }
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private func dockTile(title: String, icon: String, isActive: Bool) -> some View {
        VStack(spacing: 3) {
            ZStack {
                if isActive {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.NeoBrutal.ink)
                        .offset(x: 2, y: 2)
                }
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isActive ? Color.NeoBrutal.lavender : Color.white)
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.NeoBrutal.ink, lineWidth: 1.5)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.NeoBrutal.ink)
            }
            .frame(width: 44, height: 38)

            Text(title)
                .font(.system(size: 11, weight: isActive ? .bold : .medium, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.ink)
        }
        .frame(maxWidth: .infinity)
    }

    private var statusTitle: String {
        switch authManager.currentMode {
        case .localOnly:
            return "Local-Only Mode"
        case .authenticated:
            return "Authenticated Account"
        case .welcome:
            return "Local-Only Mode"
        }
    }

    private var statusSubtitle: String {
        switch authManager.currentMode {
        case .localOnly:
            return "On-Device"
        case .authenticated:
            return consentManager.isPersonalizationConsented ? "Cloud Sync" : "Local Storage"
        case .welcome:
            return "On-Device"
        }
    }
}

#Preview {
    HomeView()
}
