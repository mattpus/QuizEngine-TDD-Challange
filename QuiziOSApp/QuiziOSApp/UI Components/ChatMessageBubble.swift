//
//  ChatMessageBubble.swift
//  QuiziOSApp
//
//  Created by Matt on 29/10/2025.
//

import SwiftUI
import QuizEngineiOS

struct ChatMessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom) {
            if message.role == .assistant {
                bubble
                Spacer()
            } else {
                Spacer()
                bubble
            }
        }
    }
    
    private var bubble: some View {
        VStack(alignment: message.role == .assistant ? .leading : .trailing, spacing: 6) {
            Text(message.text)
                .font(.body)
                .foregroundColor(message.role == .assistant ? .primary : .white)
                .padding(12)
                .background(message.role == .assistant ? Color(.systemGray5) : Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            if let url = message.imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    case .failure:
                        Link(url.absoluteString, destination: url)
                            .font(.footnote)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: message.role == .assistant ? .leading : .trailing)
    }
}

#Preview("Assistant role bubbles") {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Text("text Only:")
            ChatMessageBubble(message: ChatMessage(
                role: .assistant,
                text: "Hello! How can I help you today?",
                imageURL: nil
            ))
            Text("with image:")
            ChatMessageBubble(message: ChatMessage(
                role: .assistant,
                text: "Here's an image related to your quiz topic:",
                imageURL: URL(string: "url-to-image")
            ))
        }
        .padding()
    }
    .background(Color(.systemBackground))
}


#Preview("User role bubbles") {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Text("text Only:")
            ChatMessageBubble(message: ChatMessage(
                role: .user,
                text: "Show me today's quiz and include an image, please.",
                imageURL: nil
            ))
            Text("with image:")
            ChatMessageBubble(message: ChatMessage(
                role: .user,
                text: "Great, I found this too!",
                imageURL: URL(string: "url-to-image")
            ))
        }
        .padding()
    }
    .background(Color(.systemBackground))
}
