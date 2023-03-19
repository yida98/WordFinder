//
//  AppData.swift
//  Lexiscope
//
//  Created by Yida Zhang on 12/17/22.
//

import Foundation
import CoreData

class AppData: ObservableObject {
    init() {
        DataManager.shared.nukeRecall()
        if DataManager.shared.retrieveUser() == nil {
            DataManager.shared.createUser()
        }
    }
}
