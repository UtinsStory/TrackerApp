//
//  TrackerRecordStore.swift
//  TrackerApp
//
//  Created by Гена Утин on 24.10.2024.
//
import UIKit
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStoreDidUpdate()
}

final class TrackerRecordStore: NSObject {
    weak var delegate: TrackerRecordStoreDelegate?
    
    private let managedObjectContext: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
    
    init(managedObjectContext: NSManagedObjectContext = CoreDataMain.shared.persistentContainer.viewContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
        
        setupFetchResultsController()
    }
    func setupFetchResultsController() {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)]
        
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
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
                
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerRecordStoreDidUpdate()
    }
}

extension TrackerRecordStore {
    func addTrackerRecord(for tracker: TrackerCoreData, date: Date) {
        let newRecord = TrackerRecordCoreData(context: managedObjectContext)
        newRecord.id = UUID()
        newRecord.tracker = tracker
        newRecord.date = date
        
        saveContext()
        
    }
    
    func removeTrackerRecord(for tracker: TrackerCoreData, date: Date) {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker == %@ AND date == %@", tracker, date as CVarArg)
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            for result in results {
                managedObjectContext.delete(result)
            }
            saveContext()
        } catch {
            print("Failed to fetch tracker records: \(error)")
        }
    }
    
    func isTrackerCompletedToday(tracker: TrackerCoreData, date: Date) -> Bool {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker == %@ AND date == %@", tracker, date as CVarArg)
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return !results.isEmpty
        } catch {
            print("Failed to fetch tracker records: \(error)")
            return false
        }
    }
    
    func completedDaysCount(for tracker: TrackerCoreData) -> Int {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker == %@", tracker)
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return results.count
        } catch {
            print("Failed to fetch tracker records: \(error)")
            return 0
        }
    }
    
    func getCompletedTrackersCount() -> Int {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest)
            return records.count
        } catch {
            print("Failed to fetch tracker records: \(error)")
            return 0
        }
    }
    
    func deleteAllTrackerRecords(with trackerID: UUID) {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker.id == %@", trackerID as CVarArg)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest)
            for record in records {
                managedObjectContext.delete(record)
            }
            saveContext()
            delegate?.trackerRecordStoreDidUpdate()
        } catch {
            print("Failed to delete tracker records: \(error)")
        }
    }
    
}
