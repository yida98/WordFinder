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
    
    func retrieveUser() -> NSManagedObject? {
        let managedContext = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        do {
            let results = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if results.count > 0 {
                return results[0]
            } else {
                return nil
            }
        } catch {
            fatalError("Unable to fetch user. \(error)")
        }
    }
    
    func retrieveEntries() -> [String: HeadwordEntry]? {
        guard let user = retrieveUser() else { return nil }
        
        let entryKey = "oxfordEntries"
        
        if let entries = user.value(forKey: entryKey) as? [String: HeadwordEntry] {
            return entries
        }
        
        return nil
    }
    
    func retrieveEntry(_ word: String) -> HeadwordEntry? {
        /// Assuming there is only one user.
        guard let entries = retrieveEntries() else { return nil }
        
        var entry: HeadwordEntry?
        if entries.contains(where: { $0.key == word }) {
            entry = entries[word]
        }
        
        return entry
    }
    
    func saveEntry(_ entry: HeadwordEntry) {
        /// Assuming there is only one user.
        guard let user = retrieveUser() else { return }
        let entryKey = "oxfordEntries"
        var entries = retrieveEntries() ?? [String: HeadwordEntry]()
        entries[entry.word] = entry
        
        user.setValue(entries, forKey: entryKey)
        
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
