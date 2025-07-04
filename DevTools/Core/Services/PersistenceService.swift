//
//  PersistenceService.swift
//  DevTools
//
//  Created by Khanh Le on 9/6/25.
//

import Foundation
import CoreData

/// Service for handling data persistence across the app
/// Thread-safe by being isolated to MainActor (Core Data operations should run on main thread)
@MainActor
final class PersistenceService: Sendable {
    
    /// Shared instance
    static let shared = PersistenceService()
    
    private init() {}
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DevTools")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // Log the error for debugging
                print("⚠️ Core Data error: \(error.localizedDescription)")
                print("Error details: \(error.userInfo)")
                
                // In production, we could:
                // 1. Show user-friendly error message
                // 2. Attempt to recover by deleting and recreating the store
                // 3. Fall back to in-memory store
                // 4. Disable persistence features gracefully
                
                // For now, we'll continue with a potentially corrupted store
                // rather than crashing the entire app
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data Operations
    
    /// Save the managed object context
    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
    
    /// Fetch entities with predicate
    func fetch<T: NSManagedObject>(_ type: T.Type, predicate: NSPredicate? = nil) -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        request.predicate = predicate
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }
    
    /// Delete an object
    func delete(_ object: NSManagedObject) {
        viewContext.delete(object)
        save()
    }
    
    func deleteHistoryItems(with ids: [UUID]) {
        let fetchRequest: NSFetchRequest<HistoryItem> = HistoryItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id IN %@", ids)

        do {
            let itemsToDelete = try viewContext.fetch(fetchRequest)
            for item in itemsToDelete {
                viewContext.delete(item)
            }
            save()
        } catch {
            print("Failed to fetch or delete history items: \(error)")
        }
    }
    
    // MARK: - UserDefaults Convenience
    
    private let userDefaults = UserDefaults.standard
    
    /// Store user preferences
    func setPreference<T>(_ value: T, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
    
    /// Get user preferences
    func getPreference<T>(_ type: T.Type, forKey key: String) -> T? {
        return userDefaults.object(forKey: key) as? T
    }
    
    /// Get user preference with default value
    func getPreference<T>(_ type: T.Type, forKey key: String, defaultValue: T) -> T {
        return userDefaults.object(forKey: key) as? T ?? defaultValue
    }
    
    /// Remove preference
    func removePreference(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    // MARK: - App-Specific Preferences
    
    /// Keys for common app preferences
    enum PreferenceKey {
        static let selectedSidebarRoute = "selectedSidebarRoute"
        static let windowFrame = "windowFrame"
        static let dateConverterSettings = "dateConverterSettings"
        static let jsonFormatterSettings = "jsonFormatterSettings"
        static let markdownPreviewSettings = "markdownPreviewSettings"
    }
    
    /// Get last selected sidebar route
    func getLastSelectedRoute() -> Route {
        let routeString = getPreference(String.self, forKey: PreferenceKey.selectedSidebarRoute, defaultValue: "home")
        
        switch routeString {
        case "dateConverter":
            return .dateConverter
        case "jsonFormatter":
            return .jsonFormatter
        case "markdownPreview":
            return .markdownPreview
        default:
            // For dynamic tool routes, try to parse the tool ID
            if routeString != "home" && !routeString.isEmpty {
                return .dynamicTool(routeString)
            }
            return .home
        }
    }
    
    /// Save selected sidebar route
    func saveSelectedRoute(_ route: Route) {
        let routeString: String
        switch route {
        case .home:
            routeString = "home"
        case .dateConverter:
            routeString = "dateConverter"
        case .jsonFormatter:
            routeString = "jsonFormatter"
        case .markdownPreview:
            routeString = "markdownPreview"
        case .dynamicTool(let toolId):
            routeString = toolId
        }
        setPreference(routeString, forKey: PreferenceKey.selectedSidebarRoute)
    }
} 