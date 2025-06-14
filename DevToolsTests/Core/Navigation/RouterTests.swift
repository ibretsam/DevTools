//
//  RouterTests.swift
//  DevToolsTests
//
//  Created by Khanh Le on 9/6/25.
//

import XCTest
@testable import DevTools

@MainActor
final class RouterTests: XCTestCase {
    
    var router: Router!
    
    @MainActor
    override func setUpWithError() throws {
        router = Router()
    }
    
    override func tearDownWithError() throws {
        router = nil
    }
    
    // MARK: - Navigation Tests
    
    @MainActor
    func testInitialState() {
        XCTAssertEqual(router.selectedSidebarRoute, .home)
        XCTAssertNil(router.selectedDetailRoute)
        XCTAssertTrue(router.path.isEmpty)
    }
    
    @MainActor
    func testNavigateToRoute() {
        // When
        router.navigate(to: .dateConverter)
        
        // Then
        XCTAssertEqual(router.selectedSidebarRoute, .dateConverter)
        XCTAssertEqual(router.selectedDetailRoute, .dateConverter)
    }
    
    @MainActor
    func testNavigateToRoot() {
        // Given
        router.navigate(to: .dateConverter)
        router.path.append("test")
        
        // When
        router.navigateToRoot()
        
        // Then
        XCTAssertEqual(router.selectedSidebarRoute, .home)
        XCTAssertNil(router.selectedDetailRoute)
        XCTAssertTrue(router.path.isEmpty)
    }
    
    @MainActor
    func testCanNavigateBack() {
        // Initially false
        XCTAssertFalse(router.canNavigateBack())
        
        // After adding to path
        router.path.append("test")
        XCTAssertTrue(router.canNavigateBack())
        
        // After navigating back
        router.navigateBack()
        XCTAssertFalse(router.canNavigateBack())
    }
    
    @MainActor
    func testAvailableTools() async {
        // Initialize the registry and refresh tools
        await ToolRegistry.initialize()
        router.refreshAvailableTools()
        
        // Give it a moment to load
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // The available tools should match the expected set of tools based on their routes
        let expectedTools: [Tool] = ToolRegistry.registeredTools.map { $0.route }
        XCTAssertEqual(router.availableTools, expectedTools, "Available tools should match the expected set of tools")
    }
    
    @MainActor
    func testClearDetailSelection() {
        // Given
        router.selectedDetailRoute = .dateConverter
        
        // When
        router.clearDetailSelection()
        
        // Then
        XCTAssertNil(router.selectedDetailRoute)
    }
    
    @MainActor
    func testPopToView() {
        // Given
        router.path.append("item1")
        router.path.append("item2")
        router.path.append("item3")
        
        // When
        router.popToView(count: 2)
        
        // Then
        XCTAssertEqual(router.path.count, 1)
    }
    
    @MainActor
    func testPopToViewWithExcessiveCount() {
        // Given
        router.path.append("item1")
        
        // When - try to pop more items than exist
        router.popToView(count: 5)
        
        // Then - should only pop what exists
        XCTAssertTrue(router.path.isEmpty)
    }
} 