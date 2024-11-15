//
//  CoreDataMain.swift
//  TrackerApp
//
//  Created by Гена Утин on 04.11.2024.
//
import Foundation
import CoreData

final class CoreDataMain {
    // MARK: - Core Data stack
    
    static let shared = CoreDataMain()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerModel")
        
        let description = container.persistentStoreDescriptions.first
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Store Accessors
    
    private(set) lazy var trackerStore: TrackerStore = {
        return TrackerStore(managedObjectContext: persistentContainer.viewContext)
    }()
    
    private(set) lazy var trackerCategoryStore: TrackerCategoryStore = {
        return TrackerCategoryStore(managedObjectContext: persistentContainer.viewContext)
    }()
    
    private(set) lazy var trackerRecordStore: TrackerRecordStore = {
        return TrackerRecordStore(managedObjectContext: persistentContainer.viewContext)
    }()
}
