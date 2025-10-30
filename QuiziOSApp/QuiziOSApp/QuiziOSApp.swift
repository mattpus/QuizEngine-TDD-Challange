//
//  QuiziOSApp.swift
//  QuiziOSApp
//
//  Created by Matt on 29/10/2025.
//

import SwiftUI

@main
struct QuiziOSApp: App {
    @State private var dependencies = Dependencies()
    
    var body: some Scene {
        WindowGroup {
#if DEBUG
            if let viewModel = UITestSupport.makeViewModelIfNeeded() {
                ContentView(viewModel: viewModel)
            } else {
                ContentView(viewModel: dependencies.chatViewModel)
            }
#else
            ContentView(viewModel: dependencies.chatViewModel)
#endif
        }
    }
}
