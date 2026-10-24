//
//  NeoBrutalComponents.swift
//  NeuroPulseAI
//
//  Soft Neo-Brutalist design system components, modifiers, and button styles.
//  Graphic, confident styling with 2pt ink outlines, flat pastel fills,
//  and hard offset shadows.
//

import SwiftUI

// MARK: - Color Extension for Hex Support
public extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255.0,
            green: Double((hex >> 08) & 0xff) / 255.0,
            blue: Double((hex >> 00) & 0xff) / 255.0,
            opacity: alpha
        )
    }

    enum NeoBrutal {
        public static let ink = Color(hex: 0x0A0A0A)
        public static let lavender = Color(hex: 0xD4C6F7)
        public static let mint = Color(hex: 0xD3F7B4)
        public static let peach = Color(hex: 0xF8D89A)
        public static let pink = Color(hex: 0xF6DDE8)
        public static let alertRed = Color(hex: 0xE8532B)
        public static let surface = Color(hex: 0xFFFFFF)
        public static let mutedText = Color(hex: 0x7A7A82)

        // Badge color pairs
        public static let badgePendingBg = Color(hex: 0xFDE3CF)
        public static let badgePendingFg = Color(hex: 0xD9622B)
        public static let badgeProgressBg = Color(hex: 0xDDF5D0)
        public static let badgeProgressFg = Color(hex: 0x2E7D32)
        public static let badgeCompleteBg = Color(hex: 0xE4EEF8)
        public static let badgeCompleteFg = Color(hex: 0x5B7FA6)

        // Presentation gradient
        public static let backdropStart = Color(hex: 0xE3E3E8)
        public static let backdropEnd = Color(hex: 0xF0EAFB)
    }
}

// MARK: - Card Modifier
public struct BrutalCardModifier: ViewModifier {
    public var cornerRadius: CGFloat = 24
    public var fill: Color = .white
    public var outlineWidth: CGFloat = 2
    public var hasShadow: Bool = true
    public var shadowOffset: CGFloat = 3

    public func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    if hasShadow {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.NeoBrutal.ink)
                            .offset(x: shadowOffset, y: shadowOffset)
                    }
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(fill)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.NeoBrutal.ink, lineWidth: outlineWidth)
                }
            )
    }
}

// MARK: - Inner List Row Modifier
public struct BrutalRowModifier: ViewModifier {
    public var cornerRadius: CGFloat = 16
    public var fill: Color = .white
    public var outlineWidth: CGFloat = 1.5

    public func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(fill)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.NeoBrutal.ink, lineWidth: outlineWidth)
                }
            )
    }
}

// MARK: - Chip Modifier
public struct BrutalChipModifier: ViewModifier {
    public var bg: Color
    public var fg: Color
    public var outlineWidth: CGFloat = 2
    public var hasShadow: Bool = true
    public var shadowOffset: CGFloat = 2.5

    public func body(content: Content) -> some View {
        content
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(fg)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    if hasShadow {
                        Capsule()
                            .fill(Color.NeoBrutal.ink)
                            .offset(x: shadowOffset, y: shadowOffset)
                    }
                    Capsule()
                        .fill(bg)
                    Capsule()
                        .stroke(Color.NeoBrutal.ink, lineWidth: outlineWidth)
                }
            )
    }
}

// MARK: - Primary Button Style with Tactile Physical Press
public struct BrutalButtonStyle: ButtonStyle {
    public var fill: Color = Color.NeoBrutal.lavender
    public var textColor: Color = Color.NeoBrutal.ink
    public var cornerRadius: CGFloat = 14
    public var outlineWidth: CGFloat = 2
    public var shadowOffset: CGFloat = 3
    public var minHeight: CGFloat = 52

    public init(
        fill: Color = Color.NeoBrutal.lavender,
        textColor: Color = Color.NeoBrutal.ink,
        cornerRadius: CGFloat = 14,
        outlineWidth: CGFloat = 2,
        shadowOffset: CGFloat = 3,
        minHeight: CGFloat = 52
    ) {
        self.fill = fill
        self.textColor = textColor
        self.cornerRadius = cornerRadius
        self.outlineWidth = outlineWidth
        self.shadowOffset = shadowOffset
        self.minHeight = minHeight
    }

    public func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        configuration.label
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundStyle(textColor)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: minHeight)
            .background(
                ZStack {
                    if !isPressed {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.NeoBrutal.ink)
                            .offset(x: shadowOffset, y: shadowOffset)
                    }
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(fill)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.NeoBrutal.ink, lineWidth: outlineWidth)
                }
            )
            .offset(x: isPressed ? shadowOffset : 0, y: isPressed ? shadowOffset : 0)
            .animation(.easeOut(duration: 0.12), value: isPressed)
    }
}

// MARK: - Secondary (White) Button Style
public struct BrutalSecondaryButtonStyle: ButtonStyle {
    public var cornerRadius: CGFloat = 14
    public var outlineWidth: CGFloat = 2
    public var shadowOffset: CGFloat = 3
    public var minHeight: CGFloat = 52

    public init(cornerRadius: CGFloat = 14, outlineWidth: CGFloat = 2, shadowOffset: CGFloat = 3, minHeight: CGFloat = 52) {
        self.cornerRadius = cornerRadius
        self.outlineWidth = outlineWidth
        self.shadowOffset = shadowOffset
        self.minHeight = minHeight
    }

    public func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        configuration.label
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.NeoBrutal.ink)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: minHeight)
            .background(
                ZStack {
                    if !isPressed {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.NeoBrutal.ink)
                            .offset(x: shadowOffset, y: shadowOffset)
                    }
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.white)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.NeoBrutal.ink, lineWidth: outlineWidth)
                }
            )
            .offset(x: isPressed ? shadowOffset : 0, y: isPressed ? shadowOffset : 0)
            .animation(.easeOut(duration: 0.12), value: isPressed)
    }
}

// MARK: - Compact Action Button Style (e.g. for card action "Open Experience")
public struct BrutalCompactButtonStyle: ButtonStyle {
    public var fill: Color = .white
    public var cornerRadius: CGFloat = 12
    public var outlineWidth: CGFloat = 2
    public var shadowOffset: CGFloat = 3

    public init(fill: Color = .white, cornerRadius: CGFloat = 12, outlineWidth: CGFloat = 2, shadowOffset: CGFloat = 3) {
        self.fill = fill
        self.cornerRadius = cornerRadius
        self.outlineWidth = outlineWidth
        self.shadowOffset = shadowOffset
    }

    public func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        configuration.label
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.NeoBrutal.ink)
            .padding(.horizontal, 16)
            .frame(height: 42)
            .background(
                ZStack {
                    if !isPressed {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.NeoBrutal.ink)
                            .offset(x: shadowOffset, y: shadowOffset)
                    }
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(fill)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.NeoBrutal.ink, lineWidth: outlineWidth)
                }
            )
            .offset(x: isPressed ? shadowOffset : 0, y: isPressed ? shadowOffset : 0)
            .animation(.easeOut(duration: 0.12), value: isPressed)
    }
}

// MARK: - Reusable White Outlined Icon Tile
public struct BrutalIconTile: View {
    public let iconName: String
    public var size: CGFloat = 48
    public var iconSize: CGFloat = 22
    public var cornerRadius: CGFloat = 14
    public var outlineWidth: CGFloat = 2
    public var bg: Color = .white
    public var iconColor: Color = Color.NeoBrutal.ink

    public init(
        iconName: String,
        size: CGFloat = 48,
        iconSize: CGFloat = 22,
        cornerRadius: CGFloat = 14,
        outlineWidth: CGFloat = 2,
        bg: Color = .white,
        iconColor: Color = Color.NeoBrutal.ink
    ) {
        self.iconName = iconName
        self.size = size
        self.iconSize = iconSize
        self.cornerRadius = cornerRadius
        self.outlineWidth = outlineWidth
        self.bg = bg
        self.iconColor = iconColor
    }

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(bg)
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.NeoBrutal.ink, lineWidth: outlineWidth)
            Image(systemName: iconName)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(iconColor)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Brutal Status Badge
public struct BrutalBadge: View {
    public enum Style {
        case pending
        case inProgress
        case complete
        case custom(bg: Color, fg: Color)

        var colors: (bg: Color, fg: Color) {
            switch self {
            case .pending:
                return (Color.NeoBrutal.badgePendingBg, Color.NeoBrutal.badgePendingFg)
            case .inProgress:
                return (Color.NeoBrutal.badgeProgressBg, Color.NeoBrutal.badgeProgressFg)
            case .complete:
                return (Color.NeoBrutal.badgeCompleteBg, Color.NeoBrutal.badgeCompleteFg)
            case .custom(let bg, let fg):
                return (bg, fg)
            }
        }
    }

    public let text: String
    public var style: Style = .complete
    public var hasOutline: Bool = true

    public init(_ text: String, style: Style = .complete, hasOutline: Bool = true) {
        self.text = text
        self.style = style
        self.hasOutline = hasOutline
    }

    public var body: some View {
        let (bg, fg) = style.colors
        Text(text)
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(fg)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                ZStack {
                    Capsule()
                        .fill(bg)
                    if hasOutline {
                        Capsule()
                            .stroke(Color.NeoBrutal.ink, lineWidth: 1.5)
                    }
                }
            )
    }
}

// MARK: - View Extensions
public extension View {
    func brutalCard(
        cornerRadius: CGFloat = 24,
        fill: Color = .white,
        outlineWidth: CGFloat = 2,
        hasShadow: Bool = true,
        shadowOffset: CGFloat = 3
    ) -> some View {
        modifier(
            BrutalCardModifier(
                cornerRadius: cornerRadius,
                fill: fill,
                outlineWidth: outlineWidth,
                hasShadow: hasShadow,
                shadowOffset: shadowOffset
            )
        )
    }

    func brutalRow(
        cornerRadius: CGFloat = 16,
        fill: Color = .white,
        outlineWidth: CGFloat = 1.5
    ) -> some View {
        modifier(
            BrutalRowModifier(
                cornerRadius: cornerRadius,
                fill: fill,
                outlineWidth: outlineWidth
            )
        )
    }

    func brutalChip(
        bg: Color = .white,
        fg: Color = Color.NeoBrutal.ink,
        hasShadow: Bool = true
    ) -> some View {
        modifier(
            BrutalChipModifier(
                bg: bg,
                fg: fg,
                outlineWidth: 2,
                hasShadow: hasShadow
            )
        )
    }

    func brutalInput(isFocused: Bool = false) -> some View {
        modifier(BrutalInputFieldModifier(isFocused: isFocused))
    }
}

// MARK: - Input Field Modifier
public struct BrutalInputFieldModifier: ViewModifier {
    public var isFocused: Bool = false
    public var cornerRadius: CGFloat = 14
    public var outlineWidth: CGFloat = 2
    public var shadowOffset: CGFloat = 3

    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    if isFocused {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.NeoBrutal.ink)
                            .offset(x: shadowOffset, y: shadowOffset)
                    }
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.white)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.NeoBrutal.ink, lineWidth: outlineWidth)
                }
            )
            .animation(.easeOut(duration: 0.15), value: isFocused)
    }
}

// MARK: - Destructive Brutal Button Style
public struct BrutalDestructiveButtonStyle: ButtonStyle {
    public var cornerRadius: CGFloat = 14
    public var outlineWidth: CGFloat = 2
    public var shadowOffset: CGFloat = 3
    public var minHeight: CGFloat = 52

    public init(cornerRadius: CGFloat = 14, outlineWidth: CGFloat = 2, shadowOffset: CGFloat = 3, minHeight: CGFloat = 52) {
        self.cornerRadius = cornerRadius
        self.outlineWidth = outlineWidth
        self.shadowOffset = shadowOffset
        self.minHeight = minHeight
    }

    public func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        configuration.label
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.NeoBrutal.alertRed)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: minHeight)
            .background(
                ZStack {
                    if !isPressed {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.NeoBrutal.ink)
                            .offset(x: shadowOffset, y: shadowOffset)
                    }
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.white)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.NeoBrutal.ink, lineWidth: outlineWidth)
                }
            )
            .offset(x: isPressed ? shadowOffset : 0, y: isPressed ? shadowOffset : 0)
            .animation(.easeOut(duration: 0.12), value: isPressed)
    }
}
