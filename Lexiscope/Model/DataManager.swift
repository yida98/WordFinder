//
//  DataManager.swift
//  Lexiscope
//
//  Created by Yida Zhang on 12/18/22.
//

import Foundation
import CoreData

class DataManager {
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
        guard let entity = NSEntityDescription.entity(forEntityName: "User", in: managedContext) else {
            fatalError()
        }
        return entity
    }()
    
    private func getContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func createUser() {
        let context = getContext()
        let _ = NSManagedObject(entity: userEntity, insertInto: context)
        saveContext()
    }
    
    func deleteAllUsers() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
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
    
    func retrieveEntries() -> [String: Data]? {
        guard let user = retrieveUser() else { return nil }
        
        let entryKey = "oxfordEntries"
        
        if let entries = user.value(forKey: entryKey) as? [String: Data] {
            return entries
        }
        
        return nil
    }
    
    func retrieveEntry(_ key: String) -> Data? {
        /// Assuming there is only one user.
        guard let entries = retrieveEntries() else { return nil }
        
        var entry: Data?
        if entries.contains(where: { $0.key.lowercased() == key.lowercased() }) {
            entry = entries[key.lowercased()]
        }
        
        return entry
    }
    
    func saveEntry(_ key: String, _ value: Data) {
        /// Assuming there is only one user.
        guard let user = retrieveUser() else {
            print("Unable to retrieve user.")
            return
        }
        let attributeKey = "oxfordEntries"
        var entries = retrieveEntries() ?? [String: Data]()
        entries[key.lowercased()] = value
        
        user.setValue(entries, forKey: attributeKey)
        
        saveContext()
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
    }
}
