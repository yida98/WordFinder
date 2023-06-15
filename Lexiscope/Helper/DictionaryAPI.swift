//
//  DictionaryAPI.swift
//  Lexiscope
//
//  Created by Yida Zhang on 4/12/23.
//

import Foundation
import Combine

protocol DictionaryAPI {
//    associatedtype RetrieveType: DictionaryRetrieveEntry
    
    func urlRequest(for word: String, language: AppData.Language, fields: Array<String>, strictMatch: Bool) -> URLRequest?
    func define(word: String,
                language: AppData.Language,
                fields: Array<String>,
                strictMatch: Bool) -> AnyPublisher<(String?, DictionaryRetrieveEntry?), Error>
}

struct OxfordAPI: DictionaryAPI {
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
    
    func define(word: String,
                language: AppData.Language,
                fields: Array<String>,
                strictMatch: Bool) -> AnyPublisher<(String?, DictionaryRetrieveEntry?), Error> {
        if let managedRetrieveObject = DataManager.shared.fetchRetrieve(for: word) as? Retrieve,
            let data = managedRetrieveObject.value(forKey: "data") as? Data,
            let retrieveEntry = DataManager.decodedRetrieveEntryData(data, retrieveType: RetrieveEntry.self) {
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
            .decode(type: RetrieveEntry.self, decoder: decoder)
            .map { (word, $0) }
            .eraseToAnyPublisher()
    }
}

struct MerriamWebsterAPI: DictionaryAPI {
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
    
    func define(word: String,
                language: AppData.Language,
                fields: Array<String>,
                strictMatch: Bool) -> AnyPublisher<(String?, DictionaryRetrieveEntry?), Error> {
        if let managedRetrieveObject = DataManager.shared.fetchRetrieve(for: word) as? Retrieve,
            let data = managedRetrieveObject.value(forKey: "data") as? Data,
            let retrieveEntry = DataManager.decodedRetrieveEntryData(data, retrieveType: MWRetrieveEntry.self) {
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
            .decode(type: MWRetrieveEntry.self, decoder: decoder)
            .map { (word, $0) }
            .eraseToAnyPublisher()
    }
}
