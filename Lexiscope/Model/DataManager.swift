//
//  DataManager.swift
//  Lexiscope
//
//  Created by Yida Zhang on 12/18/22.
//

import Foundation
import CoreData
import AVFoundation

class DataManager: ObservableObject {
    static let shared = DataManager()
    private let persistentContainerName: String = "OxfordEntryModel"
    
    private init() {}
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: persistentContainerName)
        container.loadPersistentStores { _, error in
            if let error = error {
                debugPrint("Persistent store loading error: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    private lazy var vocabularyEntryEntity: NSEntityDescription? = {
        let managedContext = getContext()
        return NSEntityDescription.entity(forEntityName: EntityName.vocabularyEntry.rawValue, in: managedContext)
    }()
    
    private lazy var pronunciationEntity: NSEntityDescription? = {
        let managedContext = getContext()
        return NSEntityDescription.entity(forEntityName: EntityName.pronunciation.rawValue, in: managedContext)
    }()
    
    private lazy var retrieveEntity: NSEntityDescription? = {
        let managedContext = getContext()
        return NSEntityDescription.entity(forEntityName: EntityName.retrieve.rawValue, in: managedContext)
    }()
    
    private func getContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
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
    
    func fetchVocabulary() -> [VocabularyEntry]? {
        let sortDescriptors = [NSSortDescriptor(key: "word", ascending: true)]
        let results = fetch(entity: .vocabularyEntry, sortDescriptors: sortDescriptors)
        switch results {
        case .success(let objects):
            guard let vocabularyEntries = objects as? [VocabularyEntry] else { return nil }
            return vocabularyEntries
        default:
            return nil
        }
    }
    
    /// Fetching based on the Headword can help disambiguate between them
    func fetchVocabularyEntry(for group: MWRetrieveGroup) -> VocabularyEntry? {
        let predicate = NSPredicate(format: "word == %@", group.headword)
        let results = fetch(entity: .vocabularyEntry, with: predicate)
        switch results {
        case .success(let objects):
            if let entries = objects as? [VocabularyEntry] {
                for entry in entries {
                    if entry.getHeadwordEntry() == group {
                        return entry
                    }
                }
            }
            return nil
        default:
            return nil
        }
    }
    
    func fetchDateOrderedVocabularyEntries(ascending: Bool) -> [VocabularyEntry]? {
        let sortDescriptors = [NSSortDescriptor(key: "date", ascending: ascending)]
        let results = fetch(entity: .vocabularyEntry, sortDescriptors: sortDescriptors)
        switch results {
        case .success(let objects):
            guard let vocabularyEntries = objects as? [VocabularyEntry] else { return nil }
            return vocabularyEntries
        default:
            return nil
        }
    }
    
    func fetchAllFamiliar() -> [VocabularyEntry]? {
        guard let savedVocabulary = DataManager.shared.fetchVocabulary() else {
            return nil
        }
        
        let results = savedVocabulary.filter { vocabulary in
            guard let dates = vocabulary.recallDates else { return false }
            return dates.count >= 4
        }
        
        return results
    }
    
    func hasAnyVocabulary() -> Bool {
        let managedContext = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.vocabularyEntry.rawValue)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            return results?.count ?? 0 > 0
        } catch {
            return false
        }
        
    }
    
    func saveVocabularyEntryEntity(headwordEntry: Data?, date: Date? = Date(), word: String?, notes: String?, recallDates: [Date]?) {
        guard let headwordEntryData = headwordEntry,
                let headwordEntry = DataManager.decodedData(headwordEntryData,
                                                            dataType: MWRetrieveGroup.self) else { return } // Headword type
        
        if let entry = fetchVocabularyEntry(for: headwordEntry) {
            entry.setValue(headwordEntryData, forKey: "headwordEntry")
            entry.setValue(date, forKey: "date")
            entry.setValue(word, forKey: "word")
            entry.setValue(recallDates, forKey: "recallDates")
            entry.setValue(notes, forKey: "notes")
        } else {
            guard let entityObject = vocabularyEntryEntity else { debugPrint("Could not get vocabularyEntryEntity"); return }
            let context = getContext()
            let entity = NSManagedObject(entity: entityObject, insertInto: context)
            entity.setValue(headwordEntryData, forKey: "headwordEntry")
            entity.setValue(date, forKey: "date")
            entity.setValue(word, forKey: "word")
            entity.setValue(recallDates, forKey: "recallDates")
            entity.setValue(notes, forKey: "notes")
        }
        
        saveContext()
    }
    
    func resaveVocabularyEntry(_ vocabularyEntry: VocabularyEntry) {
        saveVocabularyEntryEntity(headwordEntry: vocabularyEntry.headwordEntry, date: vocabularyEntry.date, word: vocabularyEntry.word, notes: vocabularyEntry.notes, recallDates: vocabularyEntry.recallDates)
    }
    
    func deleteVocabularyEntry(for headword: MWRetrieveGroup) { // Headword type
        guard let vocabularyEntry = DataManager.shared.fetchVocabularyEntry(for: headword) else { return }
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
            guard let entityObject = pronunciationEntity else { debugPrint("Could not get pronunciationEntity"); return }
            let entity = NSManagedObject(entity: entityObject, insertInto: context)
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
            guard let entityObject = retrieveEntity else { debugPrint("Could not get retrieveEntity"); return }
            let entity = NSManagedObject(entity: entityObject, insertInto: context)
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
    
    // MARK: - Nuke
    // TODO: Remove
    func eraseCache() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: EntityName.vocabularyEntry.rawValue)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: getContext())
        } catch {
            // TODO: handle the error
            debugPrint("error")
            return
        }
    }
    
    func nuke() {
        for entity in EntityName.allCases {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity.rawValue)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: getContext())
            } catch {
                // TODO: handle the error
                debugPrint("error")
                return
            }
        }
    }
    
    func nukeRecall() {
        if let vocabs = DataManager.shared.fetchVocabulary() {
            for vocab in vocabs {
                vocab.recallDates = nil
                DataManager.shared.resaveVocabularyEntry(vocab)
            }
        }
    }
    
    // MARK: - Save
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // TODO: Handle error
                debugPrint("Unable to save due to \(error)")
            }
        }
        self.objectWillChange.send()
    }
    
    enum EntityName: String, CaseIterable {
        typealias RawValue = String
        
        case vocabularyEntry = "VocabularyEntry"
        case pronunciation = "Pronunciation"
        case retrieve = "Retrieve"
    }
    
    static func decodedData<T: Decodable>(_ data: Data, dataType: T.Type) -> T? {
        let decoder = JSONDecoder()
        return try? decoder.decode(dataType, from: data)
    }
    
    private var soundPlayer: AVAudioPlayer?
    
    func pronounce(_ string: String?) {
        guard let string = string, let url = URL(string: string) else { return }
        pronounce(url: url)
    }
    
    func pronounce(url: URL) {
        guard let pronunciation = DataManager.shared.fetchPronunciation(for: url as NSURL) as? Pronunciation, let pronunciationData = pronunciation.pronunciation else {
            URLTask.shared.downloadAudioFileData(from: url) { [weak self] data, urlResponse, error in
                if let data = data {
                    self?.playSound(from: data)
                }
            }
            return
        }
        playSound(from: pronunciationData)
    }
    
    func playSound(from data: Data) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.soloAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            soundPlayer = try AVAudioPlayer(data: data)
            soundPlayer?.prepareToPlay()
            soundPlayer?.volume = 1
            soundPlayer?.play()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
}

// MARK: - NIGHTMARE

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
