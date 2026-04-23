//
//  ContentView.swift
//  SendMessage
//
//  Created by electrozone on 3/27/26.
//

import SwiftUI

struct ContentView: View {
    @State private var messageInput: String = ""
    @State private var resultText: String = ""

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("보낸 내용")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Text(String(format: "%@", resultText.isEmpty ? "아직 보낸 메세지가 없어요." : resultText))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding()
                        .background(Color.clear)
                        .overlay(
                            Rectangle()
                                .stroke(Color.gray, lineWidth: 3)
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                VStack(alignment: .leading, spacing: 14) {
                    Text("메세지")
                        .font(.headline)

                    HStack(spacing: 18) {
                        TextField("메세지를 입력하세요", text: $messageInput)
                            .textFieldStyle(.roundedBorder)
                    }

                    HStack(spacing: 18) {
                        Button("보내기", action: sendMessage)
                            .buttonStyle(.plain)

                        emojiButton("😊")
                        emojiButton("🥰")
                        emojiButton("😎")
                    }
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .frame(
                maxWidth: .infinity,
                minHeight: geometry.size.height - 80,
                maxHeight: .infinity,
                alignment: .top
            )
        }
        .padding(.horizontal, 36)
        .padding(.vertical, 40)
        .background(Color.white)
    }

    private func sendMessage() {
        let trimmedMessage = messageInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }

        resultText = resultText.isEmpty
            ? String(format: "%@", trimmedMessage)
            : String(format: "%@\n%@", resultText, trimmedMessage)
        messageInput = ""
    }

    private func emojiButton(_ emoji: String) -> some View {
        Button(action: {
            messageInput = String(format: "%@%@", messageInput, emoji)
        }) {
            Text(emoji)
                .font(.system(size: 28))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
