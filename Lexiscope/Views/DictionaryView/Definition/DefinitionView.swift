//
//  DefinitionView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 9/19/22.
//

import SwiftUI

struct DefinitionView: View {
    @ObservedObject var viewModel: DefinitionViewModel
    var spacing: CGFloat
    var familiar: Bool = false
    
    @State var presentAlert: Bool = false
    
    var body: some View {
        VStack(spacing: viewModel.expanded ? spacing * 2 : spacing) {
            // Header
            HStack {
                Text(viewModel.headwordEntry.getWord())
                    .font(viewModel.expanded ? .largeTitleBaskerville : .titleBaskerville)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .textSelection(.enabled)
                    .foregroundColor(.pineGreen) // primaryDark
                Text("fl")
                Spacer()
                Button {
                    if viewModel.saved {
                        presentAlert = true
                    } else {
                        viewModel.bookmarkWord()
                    }
                } label: {
                    if familiar {
                        Star(cornerRadius: 1)
                            .fill(Color.darkSkyBlue)
                            .frame(width: 20, height: 20)
                    } else {
                        Image(systemName: viewModel.saved ? "bookmark.fill" : "bookmark")
                            .foregroundColor(Color.darkSkyBlue) // primary
                    }
                }.alert(isPresented: $presentAlert) {
                    Alert(title: Text("Unbookmarking"), message: Text("Are you sure you want to unbookmark \(viewModel.headwordEntry.getWord())"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Unbookmark")) {
                        viewModel.bookmarkWord()
                    })
                }
            }
            if let label = viewModel.inflectionString {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(label) // TODO: Small size
                }
            }
            Divider()
            // Pronunciation
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Text("/")
                        .font(.caption)
                        .foregroundColor(.init(white: 0.5)) // neutral
                        .padding(.vertical, 2)
                    ForEach(viewModel.allValidPronunciations.indices, id: \.self) { pronunciationIndex in
                        Button {
                            DataManager.shared.pronounce(viewModel.allValidPronunciations[pronunciationIndex].audioFile)
                        } label: {
                            Text(viewModel.allValidPronunciations[pronunciationIndex].writtenPronunciation!)
                                .font(.caption)
                                .foregroundColor(.init(white: 0.5)) // neutral
                                .padding(2)
                                .background(viewModel.allValidPronunciations[pronunciationIndex].hasAudio ? Color.verdigris.opacity(0.3) : Color.clear) // primary
                                .cornerRadius(4)
                        }
                    }
                    Text("/")
                        .font(.caption)
                        .foregroundColor(.init(white: 0.5)) // neutral
                        .padding(.vertical, 2)
                    Spacer()
                }
            }.padding(.vertical, 2)
            if let definitions = viewModel.definitions {
                ScrollView(showsIndicators: false) {
                    VStack (spacing: viewModel.expanded ? 20 : 10) {
                        ForEach(definitions.indices, id: \.self) { definitionIndex in
                            Text("oh shit")
//                            MWDefinitionView()
                        }
                    }
                }
            }
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
        let phoneticList = Array(phoneticSet).sorted()
        return "/  \(Array(phoneticList).joined(separator: ", "))  /"
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
        return headwordEntry.lexicalEntries.first?.allSenses().first?.definitions?.first ?? ""
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
        return self.definitions != nil
    }
}

struct DefinitionCard: ViewModifier {
    var familiar: Bool = false
    func body(content: Content) -> some View {
        content
            .animation(.default, value: 0.5)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(familiar ? Color.silverLakeBlue : .clear, lineWidth: 3)
                    .background(.white.opacity(0.5))
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

extension DefinitionView {
    func definitionCard(familiar: Bool = false) -> some View {
        modifier(DefinitionCard(familiar: familiar))
    }
}
