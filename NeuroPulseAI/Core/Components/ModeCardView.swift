//
//  ModeCardView.swift
//  NeuroPulseAI
//
//  Soft Neo-Brutalist primary mode card:
//  Flat pastel fill, 24 radius, 2pt ink outline, hard offset shadow (3, 3),
//  white outlined icon tile, meta tag line, and white "Open Experience" action button.
//

import SwiftUI

public struct ModeCardView: View {
    public let title: String
    public let subtitle: String
    public let meta: String
    public let iconName: String
    public let fill: Color

    public init(
        title: String,
        subtitle: String = "",
        meta: String = "",
        iconName: String,
        fill: Color = Color.NeoBrutal.lavender
    ) {
        self.title = title
        self.subtitle = subtitle
        self.meta = meta
        self.iconName = iconName
        self.fill = fill
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                // Left: White rounded-square icon tile with 2pt ink outline
                BrutalIconTile(
                    iconName: iconName,
                    size: 48,
                    iconSize: 22,
                    cornerRadius: 14,
                    outlineWidth: 2,
                    bg: .white,
                    iconColor: Color.NeoBrutal.ink
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.ink)

                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.NeoBrutal.ink.opacity(0.85))
                            .lineLimit(1)
                    }

                    if !meta.isEmpty {
                        Text(meta)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.NeoBrutal.ink.opacity(0.65))
                            .padding(.top, 2)
                    }
                }

                Spacer()
            }

            // White "Open Experience" button with outline and hard shadow
            HStack {
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                    Text("Open Experience")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundStyle(Color.NeoBrutal.ink)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.NeoBrutal.ink)
                            .offset(x: 2.5, y: 2.5)
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white)
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.NeoBrutal.ink, lineWidth: 2)
                    }
                )
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .brutalCard(cornerRadius: 24, fill: fill, outlineWidth: 2, hasShadow: true, shadowOffset: 3)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(subtitle), \(meta)")
        .accessibilityHint("Double tap to open \(title)")
    }
}

#Preview {
    VStack(spacing: 16) {
        ModeCardView(
            title: "Motor Health",
            subtitle: "Fine-motor dexterity and rhythm consistency",
            meta: "2 tests · ~5 min",
            iconName: "hand.tap.fill",
            fill: Color.NeoBrutal.lavender
        )

        ModeCardView(
            title: "MindEase",
            subtitle: "Paced breathing and mindful stillness",
            meta: "3 exercises · Calming",
            iconName: "wind",
            fill: Color.NeoBrutal.mint
        )

        ModeCardView(
            title: "Read Mind Waves",
            subtitle: "Real-time brain wave rhythm visualization",
            meta: "EEG headset · Real-time",
            iconName: "waveform.path.ecg",
            fill: Color.NeoBrutal.peach
        )
    }
    .padding()
}
