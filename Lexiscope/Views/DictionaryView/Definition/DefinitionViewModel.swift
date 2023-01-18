//
//  DefinitionViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 12/14/22.
//

import Foundation
import Combine

class DefinitionViewModel: ObservableObject {
    
    @Published var headwordEntry: HeadwordEntry?
    
    init() { }
    
}
