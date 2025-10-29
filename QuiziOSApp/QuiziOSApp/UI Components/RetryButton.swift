//
//  RetryButton.swift
//  QuiziOSApp
//
//  Created by Matt on 29/10/2025.
//

import SwiftUI

struct RetryButton: View {
    let isDisabled: Bool
    let onPress: () async -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        Button {
            Task {
                await onPress()
             
            }
        } label: {
            Image(systemName: "arrow.clockwise")
                .imageScale(.medium)
                .font(.system(size: 16, weight: .semibold))
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .accessibilityIdentifier("retry-button")
    }
}

#Preview("RetryButton States") {
    ScrollView() {
        Text("Enabled state")
            .frame(width: .infinity)
        RetryButton(isDisabled: false) {
            // Simulate async work
            try? await Task.sleep(nanoseconds: 5000_000_000)
        }
        .padding()
    
        Text("Disabled state")
        RetryButton(isDisabled: true) {
           
        }
        .padding()
        Spacer()
    }
    .padding()
    .background(Color(.secondarySystemBackground))
}
