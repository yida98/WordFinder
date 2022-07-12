//
//  Entry.swift
//  Lexiscope
//
//  Created by Yida Zhang on 7/11/22.
//

import Foundation

//protocol Entry {
//    var word: String { get }
//}

// TODO: Reassess validity
struct RetrieveEntry: Codable {
    var metadata: Dictionary<String, String>?
    var results: Array<HeadwordEntry>?
}

class HeadwordEntry: NSObject, Codable, Identifiable {
    var id: String
    var language: String
    var lexicalEntries: Array<LexicalEntry>
//    var pronunciations: Array<Pronunciation>?
    var type: String?
    var word: String
}

struct LexicalEntry: Codable, Identifiable {
    var entries: Array<Entry>
    var language: String
    var lexicalCategory: LexicalCategory
    var root: String?
    var text: String
    var id: String {
        return lexicalCategory.id
    }
    
}

struct Entry: Codable, Identifiable {
    var homographNumber: String?
    var senses: Array<Sense>?
    var pronunciations: Array<Pronunciation>?
    var id: String {
        return homographNumber ?? UUID().uuidString
    }
}

struct Pronunciation: Codable {
    var audioFile: String?
    var phoneticNotation: String?
    var phoneticSpelling: String?
    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: Keys.self)
//        let audioFile = try container.decode(String.self, forKey: .audioFile)
//        self.audioFile = audioFile
//        let phoneticNotation = try container.decode(String.self, forKey: .phoneticNotation)
//        self.phoneticNotation = phoneticNotation
//        do {
//            let phoneticSpelling = try container.decode(String.self, forKey: .phoneticSpelling)
//            self.phoneticSpelling = phoneticSpelling.unicodeScalars.first
//            print(phoneticSpelling)
//        } catch {
//            print(error)
//        }
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: Keys.self)
//        try container.encode(self.audioFile, forKey: .audioFile)
//        try container.encode(self.phoneticNotation, forKey: .phoneticNotation)
//        guard let ps = self.phoneticSpelling else {
//
//            return
//        }
//        try container.encode(ps.escaped(asASCII: false), forKey: .phoneticSpelling)
//    }
//
//    enum Keys: CodingKey {
//        case audioFile
//        case phoneticNotation
//        case phoneticSpelling
//    }
    
}

struct LexicalCategory: Category {
    var id: String
    var text: String
}

protocol Category: Codable, Identifiable {
    var id: String { get }
    var text: String { get }
}

struct Sense: Codable, Identifiable {
    var definitions: Array<String>?
    var id: String?
    var subsenses: Array<Sense>?
}
