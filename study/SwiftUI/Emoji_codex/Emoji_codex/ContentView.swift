//
//  ContentView.swift
//  Emoji_codex
//
//  Created by electrozone on 3/26/26.
//

import SwiftUI

struct ContentView: View {
    @State private var enteredEmojis: [String] = []
    @State private var animatedEmojiIndices: Set<Int> = []
    @State private var isAnimatedEmojiScaling = false

    var body: some View {
        VStack {
            Spacer()

            if !enteredEmojis.isEmpty {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 36), spacing: 8)],
                    spacing: 8
                ) {
                    ForEach(Array(enteredEmojis.enumerated()), id: \.offset) { index, emoji in
                        Text(emoji)
                            .font(.system(size: 34))
                            .scaleEffect(animatedEmojiIndices.contains(index) && isAnimatedEmojiScaling ? 1.35 : 1.0)
                    }
                }
                .padding(.horizontal, 24)
            }

            Spacer()

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    emojiButton("😀")
                    emojiButton("🥰")
                    emojiButton("🤓")
                }

                HStack(spacing: 12) {
                    deleteButton()
                    clearAllButton()
                }
            }
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }

    private func emojiButton(_ emoji: String) -> some View {
        Button {
            enteredEmojis.append(emoji)
            updateAnimationState()
        } label: {
            Text(emoji)
                .font(.system(size: 28))
                .frame(width: 56, height: 56)
                .background(Color.white)
                .overlay {
                    Rectangle()
                        .stroke(Color.blue.opacity(0.7), lineWidth: 1.5)
                }
        }
        .buttonStyle(.plain)
    }

    private func deleteButton() -> some View {
        Button {
            if !enteredEmojis.isEmpty {
                enteredEmojis.removeLast()
                updateAnimationState()
            }
        } label: {
            Image(systemName: "delete.left")
                .font(.system(size: 24))
                .foregroundStyle(.red)
                .frame(width: 56, height: 56)
                .background(Color.white)
                .overlay {
                    Rectangle()
                        .stroke(Color.red.opacity(0.7), lineWidth: 1.5)
                }
        }
        .buttonStyle(.plain)
    }

    private func clearAllButton() -> some View {
        Button {
            enteredEmojis.removeAll()
            resetAnimation()
        } label: {
            Text("Clear")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.red)
                .frame(width: 88, height: 56)
                .background(Color.white)
                .overlay {
                    Rectangle()
                        .stroke(Color.red.opacity(0.7), lineWidth: 1.5)
                }
        }
        .buttonStyle(.plain)
    }

    private func updateAnimationState() {
        var nextAnimatedIndices: Set<Int> = []
        var currentEmoji: String?
        var consecutiveCount = 0

        for (index, emoji) in enteredEmojis.enumerated() {
            if emoji == currentEmoji {
                consecutiveCount += 1
            } else {
                currentEmoji = emoji
                consecutiveCount = 1
            }

            if consecutiveCount % 5 == 0 {
                nextAnimatedIndices.insert(index)
            }
        }

        animatedEmojiIndices = nextAnimatedIndices

        guard !animatedEmojiIndices.isEmpty else {
            resetAnimation()
            return
        }

        isAnimatedEmojiScaling = false

        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            isAnimatedEmojiScaling = true
        }
    }

    private func resetAnimation() {
        animatedEmojiIndices.removeAll()
        isAnimatedEmojiScaling = false
    }
}

#Preview {
    ContentView()
}
