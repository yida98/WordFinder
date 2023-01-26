//
//  URLTask.swift
//  Lexiscope
//
//  Created by Yida Zhang on 12/14/22.
//

import Foundation
import Combine

class URLTask {
    static let shared = URLTask()
    
    private static let urlBase = "https://od-api.oxforddictionaries.com/api/v2/entries/"
    private static let appId = "b68e6b0c"
    private static let appKey = "925663b99eb05101c30ba2deea94cac6"
    
    static let default_language: URLTask.Language = .en_us
    
    private init() { }
    
    func define(word: String,
                language: URLTask.Language = URLTask.default_language,
                fields: Array<String> = ["definitions", "pronunciations"],
                strictMatch: Bool = false) -> AnyPublisher<RetrieveEntry?, Error> {
        var trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        trimmedWord = trimmedWord.lowercased()
        debugPrint(trimmedWord)
        
        if let managedVocabularyObject = DataManager.shared.fetchVocabularyEntry(for: trimmedWord), let retrieveEntryData = managedVocabularyObject.value(forKey: "retrieveEntry") as? Data {
            do {
                let retrieveEntry = try JSONDecoder().decode(RetrieveEntry.self, from: retrieveEntryData)
                    return Just(retrieveEntry).setFailureType(to: Error.self).eraseToAnyPublisher()
            } catch {
                fatalError("Unable to decode \(trimmedWord). \(error)")
            }
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
        
        var decoder = JSONDecoder()
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap {
                if let response = $0.response as? HTTPURLResponse, response.statusCode == HTTPStatusCode.OK.rawValue {
                    DataManager.shared.saveVocabularyEntryEntity(retrieveEntry: $0.data, word: trimmedWord)
                    return $0.data
                } else {
                    print("[ERROR] bad response")
                    throw NetworkError.badResponse
                }
            }
            .decode(type: RetrieveEntry.self, decoder: decoder)
            .map { $0 }
            .eraseToAnyPublisher()

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
