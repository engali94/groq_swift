//
//  Theme.swift
//  GroqChatDemo
//
//  Created by Ali Hilal on 23/02/2025.
//

import SwiftUI

enum Theme: String, CaseIterable, Identifiable {
    case modern, midnight, nature, sunset

    var id: String { rawValue }

    var name: String {
        switch self {
        case .modern: return "Modern"
        case .midnight: return "Midnight"
        case .nature: return "Nature"
        case .sunset: return "Sunset"
        }
    }

    var icon: String {
        switch self {
        case .modern: return "circle.hexagongrid.fill"
        case .midnight: return "moon.stars.fill"
        case .nature: return "leaf.fill"
        case .sunset: return "sun.horizon.fill"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .modern: return Color(.systemBackground)
        case .midnight: return Color.black
        case .nature: return Color(.systemBackground)
        case .sunset: return Color(.systemBackground).opacity(0.95)
        }
    }

    var titleColor: Color {
        switch self {
        case .modern: return .primary
        case .midnight: return .white
        case .nature: return .green
        case .sunset: return .orange
        }
    }

    var subtitleColor: Color {
        switch self {
        case .modern: return .secondary
        case .midnight: return .gray
        case .nature: return .green.opacity(0.7)
        case .sunset: return .orange.opacity(0.7)
        }
    }

    var userBubbleColor: Color {
        switch self {
        case .modern: return .blue
        case .midnight: return .indigo
        case .nature: return .green
        case .sunset: return .orange
        }
    }

    var assistantBubbleColor: Color {
        switch self {
        case .modern: return Color(.secondarySystemBackground)
        case .midnight: return Color.gray.opacity(0.2)
        case .nature: return Color.green.opacity(0.1)
        case .sunset: return Color.orange.opacity(0.1)
        }
    }

    var userTextColor: Color { .white }
    var assistantTextColor: Color { .primary }

    var inputBackgroundColor: Color {
        switch self {
        case .modern: return Color(.secondarySystemBackground)
        case .midnight: return Color.gray.opacity(0.2)
        case .nature: return Color.green.opacity(0.1)
        case .sunset: return Color.orange.opacity(0.1)
        }
    }

    var inputBorderColor: Color {
        switch self {
        case .modern: return Color(.separator)
        case .midnight: return Color.gray.opacity(0.3)
        case .nature: return Color.green.opacity(0.3)
        case .sunset: return Color.orange.opacity(0.3)
        }
    }

    var bottomBarColor: Color {
        switch self {
        case .modern: return Color(.systemBackground)
        case .midnight: return Color.black
        case .nature: return Color(.systemBackground)
        case .sunset: return Color(.systemBackground)
        }
    }

    var dividerColor: Color {
        switch self {
        case .modern: return Color(.separator)
        case .midnight: return Color.gray.opacity(0.3)
        case .nature: return Color.green.opacity(0.3)
        case .sunset: return Color.orange.opacity(0.3)
        }
    }

    var buttonEnabledColor: Color {
        switch self {
        case .modern: return .blue
        case .midnight: return .indigo
        case .nature: return .green
        case .sunset: return .orange
        }
    }

    var buttonDisabledColor: Color {
        switch self {
        case .modern: return Color(.tertiaryLabel)
        case .midnight: return Color.gray.opacity(0.5)
        case .nature: return Color.green.opacity(0.5)
        case .sunset: return Color.orange.opacity(0.5)
        }
    }

    var userAvatarColor: Color {
        switch self {
        case .modern: return .blue.opacity(0.2)
        case .midnight: return .indigo.opacity(0.2)
        case .nature: return .green.opacity(0.2)
        case .sunset: return .orange.opacity(0.2)
        }
    }

    var assistantAvatarColor: Color {
        switch self {
        case .modern: return Color(.secondarySystemBackground)
        case .midnight: return Color.gray.opacity(0.2)
        case .nature: return Color.green.opacity(0.1)
        case .sunset: return Color.orange.opacity(0.1)
        }
    }

    var userAvatarIconColor: Color { userBubbleColor }
    var assistantAvatarIconColor: Color { .secondary }

    var accentColor: Color { userBubbleColor }
}
