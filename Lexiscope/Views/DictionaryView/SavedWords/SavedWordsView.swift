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
                    Text("No bookmarks")
                        .placeholder()
                } else {
                    ScrollView(showsIndicators: false) {
                        ForEach(viewModel.sectionTitles ?? [String](), id: \.self) { key in
                            Section {
                                ForEach(display(at: key)) { entry in
                                    DefinitionView(viewModel: DefinitionViewModel(headwordEntry: entry.getHeadwordEntry(),
                                                                                  saved: true,
                                                                                  expanded: false),
                                                   spacing: 3,
                                                   familiar: entry.recallDates?.count ?? 0 >= 4)
                                    .definitionCard(familiar: entry.recallDates?.count ?? 0 >= 4)
                                    .onTapGesture {
                                        viewModel.presentingVocabularyEntry = entry
                                        if viewModel.presentingVocabularyEntry != nil {
                                            viewModel.isPresenting = true
                                        }
                                    }
                                    .contextMenu(menuItems: {
                                        Button {
                                            showShareSheet(vocabularyEntry: entry)
                                        } label: {
                                            Label("Share definition", systemImage: "square.and.arrow.up")
                                        }
                                    })
                                    .id(entry.word)
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
                if let entry = viewModel.presentingVocabularyEntry {
                    FullSavedWordView(viewModel: FullSavedWordViewModel(headwordEntry: entry.getHeadwordEntry(),
                                                                     saved: true))
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
        var items: [String] = ["\"\(vocabularyEntry.getHeadwordEntry().word.capitalized)\" is defined as:"]
        if let sense = vocabularyEntry.getHeadwordEntry().allSenses().first(where: { sense in
            sense.hasDefinitions
        }), let definitions = sense.definitions {
            items.append(contentsOf: definitions)
        }
        items = [String(items.joined(separator: "\n"))]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        UIApplication.shared.currentUIWindow()?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
}

extension VocabularyEntry {
    func getHeadwordEntry() -> MWRetrieveEntry {
        guard let result = DataManager.decodedData(self.headwordEntry!, dataType: MWRetrieveEntry.self) else { fatalError("No headword entry") }
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
