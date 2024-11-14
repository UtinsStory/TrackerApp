//
//  TrackerCategoryStore.swift
//  TrackerApp
//
//  Created by Гена Утин on 24.10.2024.
//
import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidChangeContent(_ store: TrackerCategoryStore)
}

final class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    weak var delegate: TrackerCategoryStoreDelegate?
    private let managedObjectContext: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    
    init(managedObjectContext: NSManagedObjectContext = CoreDataMain.shared.persistentContainer.viewContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
        
        setupFetchResultsController()
    }
    
    func fetchCategory(by header: String) -> TrackerCategoryCoreData? {
            let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "header == %@", header)
            return try? managedObjectContext.fetch(request).first
        }
        
        func createCategory(header: String) {
            if fetchCategory(by: header) == nil {
                let category = TrackerCategoryCoreData(context: managedObjectContext)
                category.header = header
                saveContext()
            }
        }
        
        func fetchCategories() -> [TrackerCategory] {
            let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
            do {
                let categoryEntities = try managedObjectContext.fetch(fetchRequest)
                return categoryEntities.map { TrackerCategory(header: $0.header ?? "", trackers: []) }
            } catch let error as NSError {
                print(error.userInfo)
                return []
            }
        }
    
    
    func setupFetchResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "header", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: managedObjectContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error performing fetch: \(error)")
        }
    }
    
    private func saveContext() {
        let context = CoreDataMain.shared.persistentContainer.viewContext
        if context.hasChanges {
            context.registeredObjects.forEach { managedObject in
                if managedObject.hasChanges {
                    print("Изменённый объект: \(managedObject.entity.name ?? "Unknown Entity"), Статус: \(managedObject.changedValues())")
                }
            }
            do {
                try context.save()
                print("Контекст успешно сохранён")
            } catch {
                let nserror = error as NSError
                print("Не удалось сохранить контекст. \(nserror), \(nserror.userInfo)")
            }
        } else {
            print("Нет изменений для сохранения в контексте")
        }
    }
}
