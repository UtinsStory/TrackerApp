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
    
    func deleteTrackerAndRecords(trackerId: UUID) {
        if let trackerCoreData = fetchTracker(by: trackerId) {
            CoreDataMain.shared.trackerRecordStore.deleteAllTrackerRecords(with: trackerId)
            managedObjectContext.delete(trackerCoreData)
            saveContext()
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
            var categories = categoryEntities.map { categoryEntity in
                let trackers = categoryEntity.trackers?.allObjects as? [TrackerCoreData] ?? []
                let trackerModels = trackers.map { Tracker(trackerCoreData: $0) }
                return TrackerCategory(header: categoryEntity.header ?? "Без категории", trackers: trackerModels)
            }
            
            if let completedCategoryIndex = categories.firstIndex(where: { $0.header == "Закрепленные" }) {
                let completedCategory = categories.remove(at: completedCategoryIndex)
                categories.insert(completedCategory, at: 0)
            }
            
            return categories
        } catch let error as NSError {
            print("Error fetching categories: \(error), \(error.userInfo)")
            return []
        }
    }
    
}

extension TrackerStore {
    
    func pinTracker(_ trackerId: UUID) {
        guard let trackerCoreData = fetchTracker(by: trackerId) else { return }
        
        if let currentCategory = trackerCoreData.category {
            currentCategory.removeFromTrackers(trackerCoreData)
            trackerCoreData.backupCategory = currentCategory.header
        }
        
        let pinnedCategory = createCategoryIfNotExists(with: LocalizationHelper.localizedString("pinned"))
        trackerCoreData.category = pinnedCategory
        pinnedCategory.addToTrackers(trackerCoreData)
        
        saveContext()
    }
    
    func unpinTracker(_ trackerId: UUID) {
        guard let trackerCoreData = fetchTracker(by: trackerId) else { return }
        
        if let pinnedCategory = trackerCoreData.category, pinnedCategory.header == LocalizationHelper.localizedString("pinned") {
            pinnedCategory.removeFromTrackers(trackerCoreData)
        }
        
        if let originalCategoryTitle = trackerCoreData.backupCategory {
            if let originalCategory = fetchCategory(by: originalCategoryTitle) {
                trackerCoreData.category = originalCategory
                originalCategory.addToTrackers(trackerCoreData)
                trackerCoreData.backupCategory = nil
            } else {
                let newCategory = createCategoryIfNotExists(with: originalCategoryTitle)
                trackerCoreData.category = newCategory
                newCategory.addToTrackers(trackerCoreData)
                trackerCoreData.backupCategory = nil
            }
        }
        saveContext()
    }
    
    private func createCategoryIfNotExists(with header: String) -> TrackerCategoryCoreData {
        if let existingCategory = fetchCategory(by: header) {
            return existingCategory
        } else {
            let newCategory = TrackerCategoryCoreData(context: managedObjectContext)
            newCategory.header = header
            saveContext()
            return newCategory
        }
    }
    
    private func fetchCategory(by header: String) -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "header == %@", header)
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Failed to fetch category: \(error)")
            return nil
        }
    }
}

extension TrackerStore {
    func convertToCoreData(tracker: Tracker) -> TrackerCoreData? {
        return fetchTracker(by: tracker.id)
    }
}

extension TrackerStore {
    func updateTracker(id: UUID, title: String, color: String, emoji: String, schedule: [WeekDay]?, categoryTitle: String) {
        guard let trackerCoreData = fetchTracker(by: id) else { return }
        
        trackerCoreData.title = title
        trackerCoreData.color = color
        trackerCoreData.emoji = emoji
        trackerCoreData.schedule = schedule?.map { String($0.rawValue) }.joined(separator: ",")
        
        let categoryStore = TrackerCategoryStore()
        var category = categoryStore.fetchCategory(by: categoryTitle)
        if category == nil {
            categoryStore.createCategory(header: categoryTitle)
            category = categoryStore.fetchCategory(by: categoryTitle)
        }
        
        if let category = category {
            trackerCoreData.category = category
        }
        
        saveContext()
        delegate?.trackerStoreDidUpdate()
    }
}


