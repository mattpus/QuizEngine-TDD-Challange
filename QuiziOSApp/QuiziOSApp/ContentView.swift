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
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
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
