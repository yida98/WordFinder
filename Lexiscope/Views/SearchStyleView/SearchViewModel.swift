//
//  SearchViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 9/21/22.
//

import Foundation

class SearchViewModel: ObservableObject {
    // TODO: Persist default
    @Published var cameraSearch: Bool = true
    
    init() {
        
    }
}