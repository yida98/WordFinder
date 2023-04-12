//
//  DictionaryAPI.swift
//  Lexiscope
//
//  Created by Yida Zhang on 4/12/23.
//

import Foundation

protocol DictionaryAPI {
    func urlRequest(for word: String, language: URLTask.Language, fields: Array<String>, strictMatch: Bool) -> URLRequest?
}

struct OxfordAPI: DictionaryAPI {
    private var urlBase: String = "https://od-api.oxforddictionaries.com/api/v2/entries/"
    private var appId: String = "b68e6b0c"
    private var appKey: String = "925663b99eb05101c30ba2deea94cac6"
    
    func urlRequest(for word: String, language: URLTask.Language, fields: Array<String>, strictMatch: Bool) -> URLRequest? {
        guard let requestURL = requestURL(for: word, in: language, fields: fields, strictMatch: strictMatch), let url = URL(string: requestURL) else { return nil }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(appId, forHTTPHeaderField: "app_id")
        request.addValue(appKey, forHTTPHeaderField: "app_key")
        
        return request
    }
    
    private func requestURL(for word_id: String,
                                   in language: URLTask.Language = URLTask.default_language,
                                   fields: Array<String> = [],
                                   strictMatch: Bool = false) -> String? {
        guard let encodedURL = word_id.lowercased().encodeUrl() else {
            return nil
        }
        return "\(urlBase)\(language.rawValue)/\(encodedURL)?fields=\(fields.joined(separator: "%2C"))&strictMatch=\(strictMatch)"
    }
}

struct MerriamWebsterAPI: DictionaryAPI {
    private var urlBase: String = "https://dictionaryapi.com/api/v3/references/"
    private var appKey: String = "d1814697-28ad-40e1-ba56-f787487fe73e"
    private var ref: String = "collegiate"
    
    func urlRequest(for word: String, language: URLTask.Language, fields: Array<String>, strictMatch: Bool) -> URLRequest? {
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
