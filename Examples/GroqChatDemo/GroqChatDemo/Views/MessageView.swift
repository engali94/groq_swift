//
//  MessageView.swift
//  GroqChatDemo
//
//  Created by Ali Hilal on 23/02/2025.
//

import SwiftUI

struct MessageView: View {
    let message: ChatMessage
    let theme: Theme

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if !message.isUser {
                Avatar(isUser: false, theme: theme)
            }

            if message.isUser {
                Spacer(minLength: 24)
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundStyle(message.isUser ? theme.userTextColor : theme.assistantTextColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(message.isUser ? theme.userBubbleColor : theme.assistantBubbleColor)
                    .clipShape(BubbleShape(isUser: message.isUser))

                if message.isStreaming {
                    TypingIndicator()
                        .foregroundStyle(theme.subtitleColor)
                }
            }

            if !message.isUser {
                Spacer(minLength: 24)
            }

            if message.isUser {
                Avatar(isUser: true, theme: theme)
            }
        }
    }
}

struct Avatar: View {
    let isUser: Bool
    let theme: Theme

    var body: some View {
        Circle()
            .fill(isUser ? theme.userAvatarColor : theme.assistantAvatarColor)
            .frame(width: 32, height: 32)
            .overlay {
                Image(systemName: isUser ? "person.fill" : "brain.head.profile")
                    .font(.system(size: 14))
                    .foregroundStyle(isUser ? theme.userAvatarIconColor : theme.assistantAvatarIconColor)
            }
    }
}

struct TypingIndicator: View {
    @State private var phase = 0.0

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 4, height: 4)
                    .scaleEffect(phase == Double(index) ? 1.5 : 1)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 0.6).repeatForever(autoreverses: false)) {
                phase = 2
            }
        }
    }
}

struct BubbleShape: Shape {
    let isUser: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerRadius: CGFloat = 16
        let triangleSize: CGFloat = 8

        if isUser {
            path.move(to: CGPoint(x: rect.maxX - triangleSize, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - triangleSize))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
            path.addQuadCurve(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY),
                              control: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius),
                              control: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius))
            path.addQuadCurve(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY),
                              control: CGPoint(x: rect.minX, y: rect.maxY))
        } else {
            path.move(to: CGPoint(x: rect.minX + triangleSize, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - triangleSize))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
            path.addQuadCurve(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY),
                              control: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius),
                              control: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
            path.addQuadCurve(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY),
                              control: CGPoint(x: rect.maxX, y: rect.maxY))
        }

        path.closeSubpath()
        return path
    }
}
