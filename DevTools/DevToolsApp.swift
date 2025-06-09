//
//  DevToolsApp.swift
//  DevTools
//
//  Created by Khanh Le on 9/6/25.
//

import SwiftUI

@main
struct DevToolsApp: App {
    var body: some Scene {
        WindowGroup {
            RootNavigationView()
        }
        .windowStyle(DefaultWindowStyle())
        .windowResizability(.automatic)
        .defaultSize(width: 800, height: 600)
    }
}
