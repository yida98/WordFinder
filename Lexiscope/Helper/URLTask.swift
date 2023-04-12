//
//  URLTask.swift
//  Lexiscope
//
//  Created by Yida Zhang on 12/14/22.
//

import Foundation
import Combine
import NaturalLanguage

class URLTask {
    static let shared = URLTask()
    
    private let api: any DictionaryAPI
    static let currentAPI: URLTask.API = .oxford
    
    static let default_language: URLTask.Language = .en_us
    
    private init() {
        switch URLTask.currentAPI {
        case .oxford:
            self.api = OxfordAPI()
        case .merriamWebster:
            self.api = MerriamWebsterAPI()
        }
    }
    
    func define(word: String,
                language: URLTask.Language = URLTask.default_language,
                fields: Array<String> = ["definitions", "examples", "pronunciations"],
                strictMatch: Bool = false) -> AnyPublisher<(String?, RetrieveEntry?), Error> {
        let trimmedWord = URLTask.sanitizeInput(word)
        debugPrint(trimmedWord)
        
        if let managedRetrieveObject = DataManager.shared.fetchRetrieve(for: trimmedWord) as? Retrieve,
            let data = managedRetrieveObject.value(forKey: "data") as? Data,
            let retrieveEntry = DataManager.decodedRetrieveEntryData(data) {
            return Just((trimmedWord, retrieveEntry)).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        guard let urlRequest = api.urlRequest(for: trimmedWord, language: language, fields: fields, strictMatch: strictMatch) else {
            debugPrint("[ERROR] Invalid request")
            return Fail(error: DictionaryError.badRequest).eraseToAnyPublisher()
        }
        
        let decoder = JSONDecoder()
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap {
                if let response = $0.response as? HTTPURLResponse, response.statusCode == HTTPStatusCode.OK.rawValue {
                    DataManager.shared.saveRetrieve($0.data, for: trimmedWord)
                    return $0.data
                } else {
                    print("[ERROR] bad response")
                    throw NetworkError.badResponse
                }
            }
            .decode(type: RetrieveEntry.self, decoder: decoder)
            .map { (trimmedWord, $0) }
            .eraseToAnyPublisher()

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
    
    enum Language: String {
        case en_us = "en-us"
        case en_gb = "en-gb"
        case es
        case fr
        case gu
        case hi
        case lv
        case ro
        case sw
        case ta
    }
    
    enum DictionaryError: Error {
        case noResult
        case badRequest
    }
    
    enum API {
        case oxford, merriamWebster
    }
}

enum NetworkError: Error {
    case badResponse
    case badURL
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
