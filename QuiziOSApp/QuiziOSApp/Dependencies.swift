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

final class Dependencies: ObservableObject {
    private let client: HTTPClient
    private let endpoint: URL
    private let loader : RemoteCountryLoader
    
    init(client: HTTPClient = URLSessionHTTPClient(),
         endpoint: URL = URL(string: "https://restcountries.com/v3.1/all?fields=name,capital,cca2,flag,flags")!) {
        self.client = client
        self.endpoint = endpoint
        self.loader = RemoteCountryLoader(url: endpoint, client: client)
    }
    
    lazy var chatViewModel = ChatViewModel(engine: AnswerEngine(loader: loader))
}
