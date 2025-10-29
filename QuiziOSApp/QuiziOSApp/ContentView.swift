//
//  ContentView.swift
//  QuiziOSApp
//
//  Created by Matt on 29/10/2025.
//

import SwiftUI
import QuizEngineiOS
import QuizEngineCore

struct ContentView: View {
    @ObservedObject var viewModel: ChatViewModel
    @State private var messageText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                ChatMessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                    }
                    .background(Color(.systemGroupedBackground))
                    .onChange(of: viewModel.messages) { _, messages in
                        guard let last = messages.last else { return }
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
                Divider()
                VStack(spacing: 8) {
                    HStack(alignment: .bottom, spacing: 8) {
                        TextField("Ask about a country capital, flag, or iso...", text: $messageText, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(1...4)
                            .disabled(viewModel.isLoading)
                            .accessibilityIdentifier("question-input")
                            .onSubmit(sendMessage)
                        
                        Button(action: sendMessage) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
                        .accessibilityIdentifier("submit")
                    }
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemBackground))
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    RetryButton(isDisabled: !viewModel.canRetry || viewModel.isLoading) {
                        await viewModel.retry()
                    }
                }
            }
            .alert(item: errorBinding) { error in
                Alert(
                    title: Text("Connection Issue"),
                    message: Text(error.message),
                    primaryButton: .default(Text("Retry")) {
                        Task { await viewModel.retry() }
                    },
                    secondaryButton: .cancel {
                        viewModel.dismissError()
                    }
                )
            }
        }
    }
    
    private var errorBinding: Binding<ErrorMessage?> {
        Binding(
            get: { viewModel.error },
            set: { newValue in
                if newValue == nil {
                    viewModel.dismissError()
                }
            }
        )
    }
    
    private func sendMessage() {
        let question = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty else { return }
        let rawQuestion = messageText
        messageText = ""
        Task {
            await viewModel.send(question: rawQuestion)
        }
    }
}


#Preview {
    struct PreviewEngine: AnswerProvider {
        func answer(for question: String) async throws -> CountryAnswer {
            CountryAnswer(text: "Sample answer for \(question)", imageURL: nil)
        }
    }
    let viewModel = ChatViewModel(engine: PreviewEngine())
    return ContentView(viewModel: viewModel)
}
