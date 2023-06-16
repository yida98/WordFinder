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
    let currentAPI: MerriamWebsterAPI
    
    static var default_language: Language {
        get { return .en_us }
    }
    
    override init() {
        self.currentAPI = MerriamWebsterAPI()
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
