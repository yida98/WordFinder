//
//  AppData.swift
//  Lexiscope
//
//  Created by Yida Zhang on 12/17/22.
//

import Foundation
import CoreData
import UIKit

class AppData: NSObject, UIApplicationDelegate {
    private let currentAPI: URLTask.API
    let api: DictionaryAPI
    
    static let default_language: Language = .en_us
    
    convenience override init() {
        self.init(api: .merriamWebster)
    }
    
    init(api: URLTask.API) {
        self.currentAPI = api
        
        let apiClass: any DictionaryAPI
        switch api {
        case .oxford:
            apiClass = OxfordAPI()
        case .merriamWebster:
            apiClass = MerriamWebsterAPI()
        }
        
        self.api = apiClass
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
}
