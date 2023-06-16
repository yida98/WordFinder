//
//  RetrieveEntry.swift
//  Lexiscope
//
//  Created by Yida Zhang on 6/14/23.
//

import Foundation

protocol DictionaryRetrieveEntry: Codable { }

protocol DictionaryHeadword: Codable, Equatable {
    func getWord() -> String
}
