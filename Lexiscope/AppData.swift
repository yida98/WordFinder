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
//        DataManager.shared.nuke()
        AppData.versioning()
    }
    
    static func versioning() {
        let existingVersion = UserDefaults.standard.object(forKey: "CurrentVersionNumber") as? String
        let appVersionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String

        if existingVersion != appVersionNumber {
            UserDefaults.standard.set(appVersionNumber, forKey: "CurrentVersionNumber")
            UserDefaults.standard.synchronize()

            DataManager.shared.nuke()
        }
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
