//
//  DevToolsApp.swift
//  DevTools
//
//  Created by Khanh Le on 9/6/25.
//

import SwiftUI

@main
struct DevToolsApp: App {
    @StateObject private var router = Router()
    
    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(router)
                .task {
                    // Initialize the tool registry at app startup
                    await ToolRegistry.initialize()
                    // Refresh router tools after registry initialization
                    router.refreshAvailableTools()
                }
        }
        .windowStyle(DefaultWindowStyle())
        .windowResizability(.automatic)
        .defaultSize(width: 800, height: 600)
    }
}
