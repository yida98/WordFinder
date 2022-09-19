//
//  LexiscopeApp.swift
//  Lexiscope
//
//  Created by Yida Zhang on 2022-05-03.
//

import SwiftUI

@main
struct LexiscopeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ContentViewModel())
        }
    }
}
