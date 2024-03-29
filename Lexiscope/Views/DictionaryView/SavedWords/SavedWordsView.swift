//
//  SavedWordsView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/17/23.
//

import SwiftUI

struct SavedWordsView: View {
    @ObservedObject var viewModel: SavedWordsViewModel
    @State var previousTitle: String = ""
    
    var body: some View {
        ScrollViewReader { reader in
            ZStack {
                if viewModel.vocabulary == nil || viewModel.vocabulary?.count == 0 {
                    Text("NO BOOKMARKS")
                        .placeholder()
                } else {
                    ScrollView(showsIndicators: false) {
                        ForEach(viewModel.sectionTitles ?? [String](), id: \.self) { key in
                            Section {
                                ForEach(display(at: key)) { entry in
                                    if let headwordEntry = entry.getHeadwordEntry() {
                                        MWRetrieveEntryView(viewModel: MWRetrieveGroupViewModel(group: headwordEntry, saved: true, expanded: false, fullScreen: false), contextualText: contextualText(for: entry))
                                            .definitionCard(familiar: entry.recallDates?.count ?? 0 > 4)
                                            .onTapGesture {
                                                viewModel.presentingVocabularyEntry = entry
                                                if viewModel.presentingVocabularyEntry != nil {
                                                    viewModel.isPresenting = true
                                                }
                                            }
                                            .contextMenu {
                                                Button {
                                                    showShareSheet(vocabularyEntry: entry)
                                                } label: {
                                                    Label("Share definition", systemImage: "square.and.arrow.up")
                                                }
                                            }
                                            .id(entry.word)
                                    } else {
                                         EmptyView()
                                    }
                                    // TODO: MWRetrieveGroup instead of MWRetrieveEntry
//                                    DefinitionView(viewModel: DefinitionViewModel(headwordEntry: entry.getHeadwordEntry(),
//                                                                                  saved: true,
//                                                                                  expanded: false),
//                                                   spacing: 3,
//                                                   familiar: entry.recallDates?.count ?? 0 >= 4)
//                                    .definitionCard(familiar: entry.recallDates?.count ?? 0 >= 4)
//                                    .onTapGesture {
//                                        viewModel.presentingVocabularyEntry = entry
//                                        if viewModel.presentingVocabularyEntry != nil {
//                                            viewModel.isPresenting = true
//                                        }
//                                    }
//                                    .contextMenu(menuItems: {
//                                        Button {
//                                            showShareSheet(vocabularyEntry: entry)
//                                        } label: {
//                                            Label("Share definition", systemImage: "square.and.arrow.up")
//                                        }
//                                    })
//                                    .id(entry.word)
                                }
                            } header: {
                                HStack {
                                    Text("\(key.uppercased())")
                                        .font(.footnote)
                                        .bold()
                                        .foregroundColor(.verdigris) // primary
                                    Spacer()
                                }
                            }.id(key)
                        }
                        HStack {
                            Text("\(viewModel.totalFamiliar) of \(viewModel.totalVocabulary) familiar")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.silverLakeBlue)
                        }.padding()
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                    HStack {
                        Spacer()
                        SectionedScrollView(sectionTitles: viewModel.sectionTitles ?? [String](), scrollProxy: reader, previousTitle: $previousTitle)
                    }
                }
            }
            .sheet(isPresented: $viewModel.isPresenting, onDismiss: {
                if let entry = viewModel.presentingVocabularyEntry {
                    DataManager.shared.resaveVocabularyEntry(entry)
                }
            }, content: {
                if let entry = viewModel.presentingVocabularyEntry, let headwordEntry = entry.getHeadwordEntry() {
                    FullSavedWordView(viewModel: FullSavedWordViewModel(headwordEntry: headwordEntry, saved: true))
                    .background(.ultraThinMaterial)
                } else {
                    EmptyView()
                }
            })
        }
    }
    
    private func handleTap(on word: String?, scrollProxy: ScrollViewProxy) {
        if let word = word {
            scrollProxy.scrollTo(word, anchor: .top)
        }
    }
    
    private func display(at key: String) -> [VocabularyEntry] {
        guard let dictionary = viewModel.vocabularyDictionary, let result = dictionary[key] else {
            return [VocabularyEntry]()
        }
        return result
    }
    
    func showShareSheet(vocabularyEntry: VocabularyEntry) {
        guard let headwordEntry = vocabularyEntry.getHeadwordEntry() else { return }
        var items: [String] = ["\"\(headwordEntry.headword.capitalized)\" is defined as:"]
        if let shortDef = headwordEntry.allShortDefs().first {
            items.append(shortDef)
        }
        items = [String(items.joined(separator: "\n"))]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        UIApplication.shared.currentUIWindow()?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
    
    private func index(forWord word: String) -> Int? {
        guard let vocabulary = viewModel.vocabulary else { return nil }
        let flatVocab = vocabulary.flatMap { $0 }
        let index = flatVocab.firstIndex { $0.word == word }?.distance(to: 0)
        return index
    }
    
    private func contextualText(for entry: VocabularyEntry) -> String? {
        guard let word = entry.word, let index = index(forWord: word) else { return nil }
        return "\(index.magnitude + 1) of \(viewModel.totalVocabulary)"
    }
}

extension VocabularyEntry {
    func getHeadwordEntry() -> MWRetrieveGroup? {
        guard let data = headwordEntry,
                let result = DataManager.decodedData(data, dataType: MWRetrieveGroup.self) else {
            if let name = word {
                DataManager.shared.deleteVocabularyEntry(named: name)
            }
            return nil
        }
        return result
    }
}

// utility extension to easily get the window
public extension UIApplication {
    func currentUIWindow() -> UIWindow? {
        let connectedScenes = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
        
        let window = connectedScenes.first?
            .windows
            .first { $0.isKeyWindow }

        return window
        
    }
}
