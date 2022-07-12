//
//  Constant.swift
//  Lexiscope
//
//  Created by Yida Zhang on 2022-05-03.
//

import Foundation
import UIKit

struct Constant {
    static let screenBounds: CGRect = UIWindow().screen.bounds
    
    // TODO: Group App Style Constants
    static let fontName = "SF Pro Text"
    
    struct URLs {
        static let settingsURL = URL(string: UIApplication.openSettingsURLString)
    }
}

class Application {
    public static var shared: Application = Application()
    
    func openSettings() {
        
    }
}
