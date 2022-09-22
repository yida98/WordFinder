//
//  DefinitionView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 9/19/22.
//

import SwiftUI

struct DefinitionView: View {
    var word: OxfordEntry.HeadwordEntry
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false, content: {
            HStack {
                Text(word.word)
                Spacer()
            }
            Text(Self.phoneticString(for: word))
            VStack {
                ForEach(word.lexicalEntries) { lexicalEntry in
                    
                    Text(lexicalEntry.lexicalCategory.text.capitalized)
                    ForEach(lexicalEntry.allSenses()) { sense in
                        if sense.definitions != nil {
                            ForEach(sense.definitions!, id: \.self) { definition in
                                Text("\(definition)")
                            }
                        } else { /// The `else` block is required to silence the excessive compile time warning
                            EmptyView()
                        }
                    }
                }
            }
        })
    }
    
    struct Style: ViewStyleSheet {
        var primaryColor: Color?
        var secondaryColor: Color?
        var backgroundColor: Color?
        var highlightColor: Color?
    }
    
    // MARK: - Entry functions
    private static func phoneticString(for word: OxfordEntry.HeadwordEntry) -> String {
        let phoneticSet = phoneticSet(for: word)
        return "/  \(Array(phoneticSet).joined(separator: ", "))  /"
    }
    
    private static func phoneticSet(for word: OxfordEntry.HeadwordEntry) -> Set<String> {
        var phoneticSet = Set<String>()
        let entries = word.lexicalEntries.flatMap { $0.entries }
        for entry in entries {
            if let p = entry.pronunciations {
                p.map {
                    $0.phoneticSpelling
                }.forEach {
                    if $0 != nil { phoneticSet.insert($0!)
                    }
                }
            }
        }
        return phoneticSet
    }
    
}

protocol ViewStyleSheet {
    var primaryColor: Color? { get }
    var secondaryColor: Color? { get }
    var backgroundColor: Color? { get }
    var highlightColor: Color? { get }
}

extension OxfordEntry.Sense: Identifiable {
    var hasDefinitions: Bool {
        return self.definitions == nil
    }
}

extension OxfordEntry.LexicalEntry {
    func allSenses() -> [OxfordEntry.Sense] {
        return self.entries.compactMap { $0.senses }.flatMap { $0 }
    }
}
