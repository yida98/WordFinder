//
//  DefinitionView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 9/19/22.
//

import SwiftUI

struct DefinitionView: View {
    @ObservedObject var viewModel: DefinitionViewModel
    @Binding var expanded: Bool
    
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
                        if expanded {
                            ForEach(headwordEntry.lexicalEntries) { lexicalEntry in
                                Text(lexicalEntry.lexicalCategory.text.capitalized) /// e.g. preposition, adjective, verb
                                ForEach(lexicalEntry.allSenses().indices) { senseIndex in
                                    HStack {
                                        VStack {
                                            Text("\(senseIndex + 1)")
                                            Spacer()
                                        }
                                        if lexicalEntry.allSenses()[senseIndex].definitions != nil {
                                            ForEach(lexicalEntry.allSenses()[senseIndex].definitions!, id: \.self) { definition in
                                                Text("\(definition)")
                                            }
                                        } else {
                                            EmptyView()
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        } else {
                            Text(collapsedLexicalCategory(for: headwordEntry))
                            Text(collapsedDefinition(for: headwordEntry))
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
            .animation(.default, value: 0.5)
            .padding()
            .background(Color(white: 0.9))
            .mask {
                RoundedRectangle(cornerRadius: 10)
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
    
    private func collapsedLexicalCategory(for headwordEntry: HeadwordEntry) -> String {
        return headwordEntry.lexicalEntries[0].lexicalCategory.text.capitalized
    }
    
    private func collapsedDefinition(for headwordEntry: HeadwordEntry) -> String {
        return headwordEntry.lexicalEntries[0].allSenses()[0].definitions![0]
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
