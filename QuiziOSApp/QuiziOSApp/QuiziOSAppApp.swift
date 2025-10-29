//
//  QuiziOSAppApp.swift
//  QuiziOSApp
//
//  Created by Matt on 29/10/2025.
//

import SwiftUI

@main
struct QuiziOSAppApp: App {
    @State private var compositionRoot = CompositionRoot()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: compositionRoot.makeChatViewModel())
        }
    }
}
