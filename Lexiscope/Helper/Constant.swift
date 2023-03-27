//
//  Constant.swift
//  Lexiscope
//
//  Created by Yida Zhang on 2022-05-03.
//

import Foundation
import UIKit
import SwiftUI

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
        guard let url = Constant.URLs.settingsURL else { return }
        UIApplication.shared.open(url)
    }
}

prefix func !(value: Binding<Bool>) -> Binding<Bool> {
    Binding<Bool>(
            get: { !value.wrappedValue },
            set: { value.wrappedValue = !$0 }
        )
}
