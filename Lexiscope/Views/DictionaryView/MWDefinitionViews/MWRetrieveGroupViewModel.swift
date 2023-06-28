//
//  MWRetrieveGroupViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 6/27/23.
//

import Foundation

class MWRetrieveGroupViewModel: ObservableObject {
    @Published var group: MWRetrieveGroup
    @Published var saved: Bool
    @Published var expanded: Bool
    
    init(group: MWRetrieveGroup, saved: Bool, expanded: Bool) {
        self.group = group
        self.saved = saved
        self.expanded = expanded
    }
    
    func bookmark() {
        if DataManager.shared.fetchVocabularyEntry(for: group) != nil {
            saved = false
            DataManager.shared.deleteVocabularyEntry(for: group)
        } else {
            saved = true
            let encoder = JSONEncoder()
            do {
                let headwordData = try encoder.encode(group)
                DataManager.shared.saveVocabularyEntryEntity(headwordEntry: headwordData,
                                                             word: group.headword,
                                                             notes: nil,
                                                             recallDates: nil)
                
                for url in group.allPronunciationURLs() {
                    URLTask.shared.downloadAudioFileData(from: url) { data, urlResponse, error in
                        if let data = data {
                            DataManager.shared.savePronunciation(url: url as NSURL,
                                                                 pronunciation: data)
                        }
                    }
                }
            } catch {
                debugPrint("Could not encode \(group) into data.")
            }
        }
    }
}
