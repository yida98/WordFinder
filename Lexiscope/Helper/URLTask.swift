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
                strictMatch: Bool = false) -> AnyPublisher<OxfordEntry.HeadwordEntry?, Error> {
        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let requestURL = URLTask.requestURL(for: trimmedWord, in: language, fields: fields, strictMatch: strictMatch) else {
            print("[ERROR] Invalid word")
            return Fail(error: LazyDictionaryError.badRequest).eraseToAnyPublisher()
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
                if $0.response is HTTPURLResponse {
                    return $0.data
                } else {
                    print("[ERROR] bad response")
                    throw NetworkError.badResponse
                }
            }
            .decode(type: OxfordEntry.RetrieveEntry.self, decoder: decoder)
            .tryMap {
                if let result = $0.results, let firstResult = result.first {
                    return firstResult
                } else {
                    print("[ERROR] no result")
                    throw LazyDictionaryError.noResult
                }
            }
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
    
    enum LazyDictionaryError: Error {
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
