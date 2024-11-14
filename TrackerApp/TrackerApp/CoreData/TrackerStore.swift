//
//  TrackerStore.swift
//  TrackerApp
//
//  Created by Гена Утин on 24.10.2024.
//
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidUpdate()
    func trackerStoreDidAddTracker(_ tracker: TrackerCoreData)
}

final class TrackerStore: NSObject {
    private let managedObjectContext: NSManagedObjectContext
    var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    weak var delegate: TrackerStoreDelegate?
    
    init(managedObjectContext: NSManagedObjectContext = CoreDataMain.shared.persistentContainer.viewContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
        
        setupFetchResultsController()
    }
    func setupFetchResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
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

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.trackerStoreDidUpdate()
    }
}

extension TrackerStore {
    
    func createTracker(title: String, color: String, emoji: String, schedule: [WeekDay]?, categoryTitle: String) {
        let newTracker = TrackerCoreData(context: managedObjectContext)
        newTracker.id = UUID()
        newTracker.title = title
        newTracker.color = color
        newTracker.emoji = emoji
        newTracker.schedule = schedule?.map { String($0.rawValue) }.joined(separator: ",")
        newTracker.creationDate = Date()
        
        let categoryStore = TrackerCategoryStore()
        var category = categoryStore.fetchCategory(by: categoryTitle)
        if category == nil {
            categoryStore.createCategory(header: categoryTitle)
            category = categoryStore.fetchCategory(by: categoryTitle)
        }
        
        if let category = category {
            let trackers = category.mutableSetValue(forKey: "trackers")
            trackers.add(newTracker)
        }
        
        saveContext()
        delegate?.trackerStoreDidAddTracker(newTracker)
    }
    
    func fetchTracker(by id: UUID) -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Failed to fetch tracker: \(error)")
            return nil
        }
    }
    
    func fetchTrackersGroupedByCategory() -> [TrackerCategory] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.relationshipKeyPathsForPrefetching = ["trackers"]
        
        do {
            let categoryEntities = try managedObjectContext.fetch(fetchRequest)
            return categoryEntities.map { categoryEntity in
                let trackers = categoryEntity.trackers?.allObjects as? [TrackerCoreData] ?? []
                let trackerModels = trackers.map { Tracker(trackerCoreData: $0) }
                return TrackerCategory(header: categoryEntity.header ?? "Без категории", trackers: trackerModels)
            }
        } catch let error as NSError {
            print("Error fetching categories: \(error), \(error.userInfo)")
            return []
        }
    }
}

