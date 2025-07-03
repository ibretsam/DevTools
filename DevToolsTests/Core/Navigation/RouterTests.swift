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
    
    override func setUpWithError() throws {
        router = Router()
    }
    
    override func tearDownWithError() throws {
        router = nil
    }
    
    // MARK: - Navigation Tests
    
    func testInitialState() {
        XCTAssertEqual(router.selectedSidebarRoute, .home)
        XCTAssertNil(router.selectedDetailRoute)
        XCTAssertTrue(router.path.isEmpty)
    }
    
    func testNavigateToRoute() {
        // When
        router.navigate(to: .dateConverter)
        
        // Then
        XCTAssertEqual(router.selectedSidebarRoute, .dateConverter)
        XCTAssertEqual(router.selectedDetailRoute, .dateConverter)
    }
    
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
    
    func testAvailableTools() {
        let expectedTools: [Route] = [.dateConverter, .jsonFormatter, .markdownPreview]
        XCTAssertEqual(router.availableTools, expectedTools)
    }
    
    func testClearDetailSelection() {
        // Given
        router.selectedDetailRoute = .dateConverter
        
        // When
        router.clearDetailSelection()
        
        // Then
        XCTAssertNil(router.selectedDetailRoute)
    }
    
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
    
    func testPopToViewWithExcessiveCount() {
        // Given
        router.path.append("item1")
        
        // When - try to pop more items than exist
        router.popToView(count: 5)
        
        // Then - should only pop what exists
        XCTAssertTrue(router.path.isEmpty)
    }
} 