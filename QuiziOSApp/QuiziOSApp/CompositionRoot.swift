//
//  CompositionRoot.swift
//  QuiziOSApp
//
//  Created by Matt on 29/10/2025.
//

import QuizEngineCore
import QuizEngineiOS
import Combine
import Foundation

final class CompositionRoot: ObservableObject {
    
    private let client: HTTPClient
    private let endpoint: URL
    init(client: HTTPClient = URLSessionHTTPClient(),
         endpoint: URL = URL(string: "https://restcountries.com/v3.1/all?fields=name,capital,cca2,flag,flags")!) {
        self.client = client
        self.endpoint = endpoint
    }
    
    func makeChatViewModel() -> ChatViewModel {
        let loader = RemoteCountryLoader(url: endpoint, client: client)
        let engine = AnswerEngine(loader: loader)
        return ChatViewModel(engine: engine)
    }
}
