//
//  ContentView.swift
//  DevTools
//
//  Created by Khanh Le on 9/6/25.
//

import SwiftUI

// Legacy ContentView - replaced by RootNavigationView
// Keeping for reference during development
struct ContentView: View {
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
    ContentView()
}
