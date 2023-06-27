//
//  DictionaryAPI.swift
//  Lexiscope
//
//  Created by Yida Zhang on 4/12/23.
//

import Foundation
import Combine

struct MerriamWebsterAPI {
    var headwordType = MWRetrieveEntry.self
    var retrieveEntryType = MWRetrieveEntries.self
    
    func define(word: String,
                language: AppData.Language,
                fields: Array<String>,
                strictMatch: Bool) -> AnyPublisher<(String?, MWRetrieveEntries?), Error> {
        if let managedRetrieveObject = DataManager.shared.fetchRetrieve(for: word) as? Retrieve,
            let data = managedRetrieveObject.value(forKey: "data") as? Data,
           let retrieveEntry = DataManager.decodedData(data, dataType: retrieveEntryType) {
            return Just((word, retrieveEntry)).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        guard let urlRequest = urlRequest(for: word, language: language, fields: fields, strictMatch: strictMatch) else {
            debugPrint("[ERROR] Invalid request")
            return Fail(error: DictionaryError.badRequest).eraseToAnyPublisher()
        }
        
        let decoder = JSONDecoder()
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { result in
                if let response = result.response as? HTTPURLResponse, response.statusCode == HTTPStatusCode.OK.rawValue {
                    DataManager.shared.saveRetrieve(result.data, for: word)
                    
                    do {
                        let entries = try decoder.decode(MWRetrieveEntries.self, from: result.data)
                        return entries
                    } catch {
                        do {
                            let suggestions = try decoder.decode([String].self, from: result.data)
                            throw NetworkError.relatedResults(suggestions)
                        }
                    }
                } else {
                    print("[ERROR] bad response")
                    throw NetworkError.badResponse
                }
            }
            .map { (word, $0) }
            .eraseToAnyPublisher()
    }
    
    private var urlBase: String = "https://dictionaryapi.com/api/v3/references/"
    private var appKey: String = "d1814697-28ad-40e1-ba56-f787487fe73e"
    private var ref: String = "collegiate"
    
    func urlRequest(for word: String, language: AppData.Language, fields: Array<String>, strictMatch: Bool) -> URLRequest? {
        guard let requestURL = requestURL(for: word), let url = URL(string: requestURL) else { return nil }
        
        var request = URLRequest(url: url)
        request.addValue(appKey, forHTTPHeaderField: "key")
        
        return request
    }
    
    private func requestURL(for word_id: String) -> String? {
        guard let encodedURL = word_id.lowercased().encodeUrl() else {
            return nil
        }
        return "\(urlBase)\(ref)/json/\(encodedURL)?key=\(appKey)"
    }
}

// MARK: - Nightmare
protocol DictionaryAPI {
    func urlRequest(for word: String, language: AppData.Language, fields: Array<String>, strictMatch: Bool) -> URLRequest?

    associatedtype HW: DictionaryHeadword
    associatedtype RE: DictionaryRetrieveEntry

    var headwordType: HW.Type { get }
    var retrieveEntryType: RE.Type { get }
}

extension DictionaryAPI {
    func define(word: String,
                language: AppData.Language,
                fields: Array<String>,
                strictMatch: Bool) -> AnyPublisher<(String?, RE?), Error> {
        if let managedRetrieveObject = DataManager.shared.fetchRetrieve(for: word) as? Retrieve,
            let data = managedRetrieveObject.value(forKey: "data") as? Data,
           let retrieveEntry = DataManager.decodedData(data, dataType: retrieveEntryType) {
            return Just((word, retrieveEntry)).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        guard let urlRequest = urlRequest(for: word, language: language, fields: fields, strictMatch: strictMatch) else {
            debugPrint("[ERROR] Invalid request")
            return Fail(error: DictionaryError.badRequest).eraseToAnyPublisher()
        }
        
        let decoder = JSONDecoder()
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { result in
                if let response = result.response as? HTTPURLResponse, response.statusCode == HTTPStatusCode.OK.rawValue {
                    DataManager.shared.saveRetrieve(result.data, for: word)
                    return result.data
                } else {
                    print("[ERROR] bad response")
                    throw NetworkError.badResponse
                }
            }
            .decode(type: retrieveEntryType, decoder: decoder)
            .map { (word, $0) }
            .eraseToAnyPublisher()
    }
}

struct OxfordAPI {    
    typealias HW = HeadwordEntry
    typealias RE = RetrieveEntry
    
    var headwordType = HeadwordEntry.self
    var retrieveEntryType = RetrieveEntry.self
    
    private var urlBase: String = "https://od-api.oxforddictionaries.com/api/v2/entries/"
    private var appId: String = "b68e6b0c"
    private var appKey: String = "925663b99eb05101c30ba2deea94cac6"
    
    func urlRequest(for word: String, language: AppData.Language, fields: Array<String>, strictMatch: Bool) -> URLRequest? {
        guard let requestURL = requestURL(for: word, in: language, fields: fields, strictMatch: strictMatch), let url = URL(string: requestURL) else { return nil }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(appId, forHTTPHeaderField: "app_id")
        request.addValue(appKey, forHTTPHeaderField: "app_key")
        
        return request
    }
    
    private func requestURL(for word_id: String,
                            in language: AppData.Language = AppData.Language.en_us,
                                   fields: Array<String> = [],
                                   strictMatch: Bool = false) -> String? {
        guard let encodedURL = word_id.lowercased().encodeUrl() else {
            return nil
        }
        return "\(urlBase)\(language.rawValue)/\(encodedURL)?fields=\(fields.joined(separator: "%2C"))&strictMatch=\(strictMatch)"
    }
    
}
