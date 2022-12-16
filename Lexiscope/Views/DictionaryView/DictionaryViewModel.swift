//
//  DictionaryViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 12/15/22.
//

import Foundation

class DictionaryViewModel: ObservableObject {
    private var definitionViewModel: DefinitionViewModel?
    
    func getDefinitionViewModel() -> DefinitionViewModel {
        guard definitionViewModel != nil else {
            return DefinitionViewModel()
        }
        return definitionViewModel!
    }

    
}
