//
//  DefinitionView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 9/19/22.
//

import SwiftUI

struct DefinitionView: View {
    @ObservedObject var viewModel: DefinitionViewModel
    
    var body: some View {
        if let retrieveEntry = viewModel.retrieveEntry, let headwordEntries = retrieveEntry.results {
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(headwordEntries) { headwordEntry in
                        HStack {
                            Text(headwordEntry.word)
                            Spacer()
                        }
                        Text(Self.phoneticString(for: headwordEntry))
                        VStack {
                            ForEach(headwordEntry.lexicalEntries) { lexicalEntry in
                                Text(lexicalEntry.lexicalCategory.text.capitalized)
                                ForEach(lexicalEntry.allSenses()) { sense in
                                    if sense.definitions != nil {
                                        ForEach(sense.definitions!, id: \.self) { definition in
                                            Text("\(definition)")
                                        }
                                    } else {
                                        EmptyView()
                                    }
                                }
                            }
                        }
                    }
                }
                HStack {
                    Spacer()
                    Button {
                        viewModel.bookmarkWord()
                    } label: {
                        Image(systemName: "rectangle.stack.badge.plus")
                            .frame(width: 40)
                            .foregroundColor(.black.opacity(0.4))
                    }
                    Button {
                        viewModel.unbookmarkWord()
                    } label: {
                        Image(systemName: "rectangle.stack.badge.minus")
                            .frame(width: 40)
                            .foregroundColor(.black.opacity(0.4))
                    }
                }
            }
        } else {
            // TODO: Placeholder view
            Spacer()
        }
    }
    
    struct Style: ViewStyleSheet {
        var primaryColor: Color?
        var secondaryColor: Color?
        var backgroundColor: Color?
        var highlightColor: Color?
    }
    
    // MARK: - Entry functions
    private static func phoneticString(for word: HeadwordEntry) -> String {
        let phoneticSet = phoneticSet(for: word)
        return "/  \(Array(phoneticSet).joined(separator: ", "))  /"
    }
    
    private static func phoneticSet(for word: HeadwordEntry) -> Set<String> {
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

extension Sense: Identifiable {
    var hasDefinitions: Bool {
        return self.definitions == nil
    }
}

extension LexicalEntry {
    func allSenses() -> [Sense] {
        return self.entries.compactMap { $0.senses }.flatMap { $0 }
    }
}
