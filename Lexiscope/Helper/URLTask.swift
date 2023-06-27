//
//  URLTask.swift
//  Lexiscope
//
//  Created by Yida Zhang on 12/14/22.
//

import Foundation
import Combine
import NaturalLanguage
import SwiftUI

class URLTask {
    @UIApplicationDelegateAdaptor var appData: AppData
    static let shared = URLTask()
    
    private init() {
    }
    
    func define<RE: DictionaryRetrieveEntry>(word: String,
                language: AppData.Language = AppData.default_language,
                fields: Array<String> = ["definitions", "examples", "pronunciations"],
                                             strictMatch: Bool = false) -> AnyPublisher<(String?, RE?), Error> {
        let trimmedWord = URLTask.sanitizeInput(word)
        debugPrint(trimmedWord)
        
        return appData.currentAPI.define(word: word,
                                    language: language,
                                    fields: fields,
                                    strictMatch: strictMatch) as! AnyPublisher<(String?, RE?), any Error>
    }
    
    static func sanitizeInput(_ input: String, shouldStem: Bool = false) -> String {
        var stem: String = input.lowercased()
        stem = stem.trimmingCharacters(in: .whitespacesAndNewlines)
        if let range = Range(NSRange(location: 0, length: stem.count), in: input), shouldStem {
            let options: NLTagger.Options = [.omitPunctuation, .joinNames, .joinContractions, .omitOther]
            let tagger = NLTagger(tagSchemes: [.lemma])
            tagger.string = stem
            let lemma = tagger.tags(in: range, unit: .word, scheme: .lemma, options: options)
            let sanitized = lemma.compactMap { $0.0?.rawValue }.joined(separator: " ")
            if !sanitized.isEmpty {
                stem = sanitized
            }
        }
        return stem
    }
    
    func downloadAudioFileData(from url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let urlRequest = URLRequest(url: url)
        let dataTask = URLSession.shared.dataTask(with: urlRequest, completionHandler: completionHandler)
        dataTask.resume()
    }
    
}

enum DictionaryError: Error {
    case noResult
    case badRequest
    case badDecoder
}

enum NetworkError: Error {
    case badResponse
    case badURL
    case relatedResults([String])
}

extension String {
    func encodeUrl() -> String? {
        return self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    }
    
    func decodeUrl() -> String? {
        return self.removingPercentEncoding
    }
}

enum HTTPStatusCode: Int {
    case OK = 200
}
