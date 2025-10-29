//
//  main.swift
//  QuizCLIApp
//
//  Created by Matt on 29/10/2025.
//

import Foundation
import QuizEngineCore
import QuizEngineCLI

func main() async {
    let io = StandardIO()
    let endpoint = URL(string: "https://restcountries.com/v3.1/all?fields=name,capital,cca2,flag,flags")!
    let client = URLSessionHTTPClient()
    let loader = RemoteCountryLoader(url: endpoint, client: client)
    let engine = AnswerEngine(loader: loader)
    let app = QuizEngineCLIApp(io: io, engine: engine)
    
    await app.run()
}

Task {
     await main()
     exit(EXIT_SUCCESS)
 }

 dispatchMain()
