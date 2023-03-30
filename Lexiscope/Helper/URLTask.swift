//
//  URLTask.swift
//  Lexiscope
//
//  Created by Yida Zhang on 12/14/22.
//

import Foundation
import Combine
import NaturalLanguage
import PorterStemmer2

class URLTask {
    static let shared = URLTask()
    
    private static let urlBase = "https://od-api.oxforddictionaries.com/api/v2/entries/"
    private static let appId = "b68e6b0c"
    private static let appKey = "925663b99eb05101c30ba2deea94cac6"
    
    static let default_language: URLTask.Language = .en_us
    
    private init() { }
    
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
        
        guard let requestURL = URLTask.requestURL(for: trimmedWord, in: language, fields: fields, strictMatch: strictMatch) else {
            print("[ERROR] Invalid word")
            return Fail(error: DictionaryError.badRequest).eraseToAnyPublisher()
        }
        
        guard let url = URL(string: requestURL) else {
            print("[ERROR] Invalid URL")
            return Fail(error: NetworkError.badURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(URLTask.appId, forHTTPHeaderField: "app_id")
        request.addValue(URLTask.appKey, forHTTPHeaderField: "app_key")
        
        let decoder = JSONDecoder()
        
        return URLSession.shared.dataTaskPublisher(for: request)
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
    
    static func sanitizeInput(_ input: String) -> String {
        var preStem: String = input.lowercased()
        preStem = preStem.trimmingCharacters(in: .whitespacesAndNewlines)
        if let stemmer = PorterStemmer(withLanguage: .English) {
            preStem = stemmer.stem(preStem)
        }
        return preStem
    }
    
    private static func requestURL(for word_id: String,
                                   in language: URLTask.Language = URLTask.default_language,
                                   fields: Array<String> = [],
                                   strictMatch: Bool = false) -> String? {
        guard let encodedURL = word_id.lowercased().encodeUrl() else {
            return nil
        }
        return "\(URLTask.urlBase)\(language.rawValue)/\(encodedURL)?fields=\(fields.joined(separator: "%2C"))&strictMatch=\(strictMatch)"
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
