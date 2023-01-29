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
    
    private lazy var pronunciationEntity: NSEntityDescription = {
        let managedContext = getContext()
        guard let entity = NSEntityDescription.entity(forEntityName: EntityName.pronunciation.rawValue, in: managedContext) else {
            fatalError()
        }
        return entity
    }()
    
    private lazy var retrieveEntity: NSEntityDescription = {
        let managedContext = getContext()
        guard let entity = NSEntityDescription.entity(forEntityName: EntityName.retrieve.rawValue, in: managedContext) else {
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
        let sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let results = fetch(entity: .vocabularyEntry, sortDescriptors: sortDescriptors)
        switch results {
        case .success(let objects):
            return objects
        default:
            return nil
        }
    }
    
    func fetchVocabulary() -> [NSManagedObject]? {
        let sortDescriptors = [NSSortDescriptor(key: "word", ascending: true)]
        let results = fetch(entity: .vocabularyEntry, sortDescriptors: sortDescriptors)
        switch results {
        case .success(let objects):
            return objects
        default:
            return nil
        }
    }
    
//    func fetchSavedVocabulary() -> [NSManagedObject]? {
//        let predicate = NSPredicate(format: "saved == YES")
//        let sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
//        let results = fetch(entity: .vocabularyEntry, with: predicate, sortDescriptors: sortDescriptors)
//        switch results {
//        case .success(let objects):
//            return objects
//        default:
//            return nil
//        }
//    }
    
    func fetchVocabularyEntry(for word: String) -> NSManagedObject? {
        let predicate = NSPredicate(format: "word == %@", word.lowercased())
        let results = fetch(entity: .vocabularyEntry, with: predicate)
        switch results {
        case .success(let objects):
            return objects?.first
        default:
            return nil
        }
    }
    
    func saveVocabularyEntryEntity(headwordEntry: Data, date: Date = Date(), word: String) {
        if fetchVocabularyEntry(for: word) == nil {
            let context = getContext()
            let entity = NSManagedObject(entity: vocabularyEntryEntity, insertInto: context)
            entity.setValue(headwordEntry, forKey: "headwordEntry")
            entity.setValue(date, forKey: "date")
            entity.setValue(word, forKey: "word")
            
            saveContext()
        }
    }
    
    func deleteVocabularyEntry(for word: String) {
        guard let vocabularyEntry = DataManager.shared.fetchVocabularyEntry(for: word) else { return }
        let context = getContext()
        context.delete(vocabularyEntry)
        
        saveContext()
    }
    
    func fetchPronunciation(for url: NSURL) -> NSManagedObject? {
        let predicate = NSPredicate(format: "url == %@", url)
        let results = fetch(entity: .pronunciation, with: predicate)
        switch results {
        case .success(let objects):
            return objects?.first
        default:
            return nil
        }
    }
    
    func savePronunciation(url: NSURL, pronunciation: Data) {
        if fetchPronunciation(for: url) == nil {
            let context = getContext()
            let entity = NSManagedObject(entity: pronunciationEntity, insertInto: context)
            entity.setValue(url, forKey: "url")
            entity.setValue(pronunciation, forKey: "pronunciation")
            
            saveContext()
        }
    }
    
    func fetchRetrieve(for word: String) -> NSManagedObject? {
        let predicate = NSPredicate(format: "word == %@", word)
        let results = fetch(entity: .retrieve, with: predicate)
        switch results {
        case .success(let objects):
            return objects?.first
        default:
            return nil
        }
    }
    
    func saveRetrieve(_ data: Data, for word: String) {
        if fetchRetrieve(for: word) == nil {
            let context = getContext()
            let entity = NSManagedObject(entity: retrieveEntity, insertInto: context)
            entity.setValue(data, forKey: "data")
            entity.setValue(word, forKey: "word")
            
            saveContext()
        }
    }
    
    func fetch(entity: EntityName, with predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> Result<[NSManagedObject]?, Error> {
        let managedContext = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            return .success(results)
        } catch let error {
            return .failure(error)
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
    
//    private func setSaved(_ saved: Bool, for entry: NSManagedObject) {
//        entry.setValue(saved, forKey: "saved")
//        saveContext()
//    }
//
//    func bookmarkNewWord(_ word: String) {
//        guard let entry = fetchVocabularyEntry(for: word.lowercased()) else {
//            debugPrint("The word \(word) is not in the cache.")
//            return
//        }
//        setSaved(true, for: entry)
//    }
//
//    func unbookmarkWord(_ word: String) {
//        guard let entry = fetchVocabularyEntry(for: word.lowercased()) else {
//            debugPrint("The word \(word) is not in the cache.")
//            return
//        }
//        setSaved(false, for: entry)
//    }
    
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
        case pronunciation = "Pronunciation"
        case retrieve = "Retrieve"
    }
    
    static func decodedRetrieveEntryData(_ data: Data) -> RetrieveEntry {
        do {
            let entry = try JSONDecoder().decode(RetrieveEntry.self, from: data)
            return entry
        } catch {
            fatalError("Unable to decode HeadwordEntry from \(data)")
        }
    }
    
    static func decodedHeadwordEntryData(_ data: Data) -> HeadwordEntry {
        do {
            let entry = try JSONDecoder().decode(HeadwordEntry.self, from: data)
            return entry
        } catch {
            fatalError("Unable to decode HeadwordEntry from \(data)")
        }
    }
}

extension HeadwordEntry {
    func allPronunciationURLs() -> [URL] {
        var urls = [URL]()
        let entries = self.lexicalEntries.flatMap { $0.entries }
        for entry in entries {
            urls.append(contentsOf: entry.allPronunciationURLs())
        }
        return urls
    }
}

extension Entry {
    func allPronunciationURLs() -> [URL] {
        var urls = [URL]()
        guard let pronunciations = self.pronunciations else { return urls }
        for pronunciation in pronunciations {
            if let audioFile = pronunciation.audioFile, let url = URL(string: audioFile) {
                urls.append(url)
            }
        }
        return urls
    }
}
