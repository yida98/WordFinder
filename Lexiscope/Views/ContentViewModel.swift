//
//  ContentViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 7/20/22.
//

import Foundation

class ContentViewModel {
    private var definitionViewModel: DefinitionViewModel?
    private var searchViewModel: SearchViewModel?
    
    func getdefinitionViewModel() -> DefinitionViewModel {
        guard definitionViewModel != nil else {
            return DefinitionViewModel()
        }
        return definitionViewModel!
    }

    func getSearchViewModel() -> SearchViewModel {
        guard searchViewModel != nil else {
            return SearchViewModel()
        }
        return searchViewModel!
    }
}
