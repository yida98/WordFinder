//
//  DataManager.swift
//  Lexiscope
//
//  Created by Yida Zhang on 12/18/22.
//

import Foundation
import CoreData

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private init() {}
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "OxfordEntryModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Persistent store loading error: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    private lazy var userEntity: NSEntityDescription = {
        let managedContext = getContext()
        guard let entity = NSEntityDescription.entity(forEntityName: EntityName.user.rawValue, in: managedContext) else {
            fatalError()
        }
        return entity
    }()
    
    private lazy var vocabularyEntryEntity: NSEntityDescription = {
        let managedContext = getContext()
        guard let entity = NSEntityDescription.entity(forEntityName: EntityName.vocabularyEntry.rawValue, in: managedContext) else {
            fatalError()
        }
        return entity
    }()
    
    private func getContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Users
    
    func createUser() {
        let context = getContext()
        let _ = NSManagedObject(entity: userEntity, insertInto: context)
        saveContext()
    }
    
    func deleteAllUsers() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: EntityName.user.rawValue)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: getContext())
        } catch let error as NSError {
            // TODO: handle the error
            debugPrint("error")
            return
        }
    }
    
    var user: NSManagedObject?
    
    func retrieveUser() -> NSManagedObject? {
        if user != nil { return self.user }
        let managedContext = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.user.rawValue)
        do {
            let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            if let results = results, results.count > 0 {
                self.user = results[0]
                return results[0]
            } else {
                return nil
            }
        } catch {
            fatalError("Unable to fetch user. \(error)")
        }
    }
    
    // MARK: - Entries
    
    private let vocabularyAttributeKey = "vocabulary"
    
    func fetchCache() -> [NSManagedObject]? {
        let managedContext = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.vocabularyEntry.rawValue)
        let sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            if let results = results, results.count > 0 {
                return results
            } else {
                return nil
            }
        } catch {
            fatalError("Unable to fetch vocabulary. \(error)")
        }
    }
    
    func fetchSavedVocabulary() -> [NSManagedObject]? {
        let managedContext = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.vocabularyEntry.rawValue)
        let predicate = NSPredicate(format: "saved == YES")
        fetchRequest.predicate = predicate
        let sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            if let results = results, results.count > 0 {
                return results
            } else {
                return nil
            }
        } catch {
            fatalError("Unable to fetch vocabulary. \(error)")
        }
    }
    
    func fetchVocabularyEntry(for word: String) -> NSManagedObject? {
        let managedContext = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.vocabularyEntry.rawValue)
        let predicate = NSPredicate(format: "word == %@", word.lowercased())
        fetchRequest.predicate = predicate
        
        let results = try? managedContext.fetch(fetchRequest) as? [NSManagedObject]
        if let results = results, results.count > 0 {
            return results[0]
        }
        return nil
    }
    
    func saveVocabularyEntryEntity(retrieveEntry: Data, date: Date = Date(), saved: Bool = false, word: String) {
        if fetchVocabularyEntry(for: word) == nil {
            let context = getContext()
            let entity = NSManagedObject(entity: vocabularyEntryEntity, insertInto: context)
            entity.setValue(retrieveEntry, forKey: "retrieveEntry")
            entity.setValue(date, forKey: "date")
            entity.setValue(saved, forKey: "saved")
            entity.setValue(word, forKey: "word")
            
            saveContext()
        }
    }
    
    // TODO: Remove
    func eraseCache() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: EntityName.vocabularyEntry.rawValue)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: getContext())
        } catch let error as NSError {
            // TODO: handle the error
            debugPrint("error")
            return
        }
    }
    
    private func setSaved(_ saved: Bool, for entry: NSManagedObject) {
        entry.setValue(saved, forKey: "saved")
        saveContext()
    }
    
    func bookmarkNewWord(_ word: String) {
        guard let entry = fetchVocabularyEntry(for: word.lowercased()) else {
            debugPrint("The word \(word) is not in the cache.")
            return
        }
        setSaved(true, for: entry)
    }
    
    func unbookmarkWord(_ word: String) {
        guard let entry = fetchVocabularyEntry(for: word.lowercased()) else {
            debugPrint("The word \(word) is not in the cache.")
            return
        }
        setSaved(false, for: entry)
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // TODO: Handle error
                fatalError("Unable to save due to \(error)")
            }
        }
        self.objectWillChange.send()
    }
    
    enum EntityName: String {
        typealias RawValue = String
        
        case user = "User"
        case vocabularyEntry = "VocabularyEntry"
    }
    
    static func decodedRetrieveEntryData(_ data: Data) -> RetrieveEntry {
        do {
            let entry = try JSONDecoder().decode(RetrieveEntry.self, from: data)
            return entry
        } catch {
            fatalError("Unable to decode RetrieveEntry from \(data)")
        }
    }
}
