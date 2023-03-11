//
//  FullSavedWordView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/30/23.
//

import SwiftUI
import Combine

struct FullSavedWordView: View {
    @ObservedObject var viewModel: FullSavedWordViewModel
    
    @State private var textEditorHeight : CGFloat = 1
    @State private var presentNotesEditor: Bool = false
    
    var body: some View {
        Group {
            VStack {
                DefinitionView(viewModel: viewModel, spacing: 10)
                HStack {
                    Text("Familiarity:")
                        .fullSavedWordSectionTitle()
                    Circle()
                        .stamp(validation: viewModel.familiarity >= 1)
                        .frame(width: 8, height: 8)
                    Circle()
                        .stamp(validation: viewModel.familiarity >= 2)
                        .frame(width: 8, height: 8)
                    Circle()
                        .stamp(validation: viewModel.familiarity >= 3)
                        .frame(width: 8, height: 8)
                    Star(cornerRadius: 0.5)
                        .stamp(validation: viewModel.familiarity >= 4)
                        .frame(width: 12, height: 12)
                    Spacer()
                    HStack {
                        Text("Added:")
                            .fullSavedWordSectionTitle()
                        Text(dateString(from: viewModel.date))
                            .font(.caption)
                            .foregroundColor(.verdigris)
                    }
                    Spacer()
                }
                VStack {
                    ZStack {
                        if viewModel.notes.isEmpty {
                            Text("Click to edit")
                                .font(.subheadline)
                                .italic()
                                .foregroundColor(.gray.opacity(0.3))
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                        } else {
                            Text(viewModel.notes)
                                .font(.subheadline)
                                .foregroundColor(.verdigrisDark)
                                .lineLimit(6)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.verdigrisLight)
                            .frame(maxWidth: .infinity)
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 10)
                    )
                    .onPreferenceChange(ViewHeightKey.self) { textEditorHeight = $0 }
                }
                .onTapGesture {
                    presentNotesEditor = true
                }
            }
            .padding(50)
        }
        .sheet(isPresented: $presentNotesEditor, onDismiss: {
            viewModel.saveVocabulary()
        }, content: {
            FullSavedWordNotesEditor(text: $viewModel.notes)
        })
        .ignoresSafeArea()
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

extension View {
    func fullSavedWordSectionTitle() -> some View {
        self
            .font(.caption)
            .foregroundColor(.verdigrisDark)
    }
}
    
extension Shape {
    func stamp(validation: Bool) -> some View {
        self
            .fill(validation ? Color.verdigrisDark : Color.verdigrisLight)
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}


class FullSavedWordViewModel: DefinitionViewModel {
    @Published var notes: String
    @Published var familiarity: Int
    @Published var date: Date
    private var subscribers = Set<AnyCancellable>()
        
    init(headwordEntry: HeadwordEntry, saved: Bool) {
        self.notes = FullSavedWordViewModel.getNotes(for: headwordEntry.word)
        self.familiarity = FullSavedWordViewModel.getFamiliarity(for: headwordEntry.word)
        self.date = Date()

        super.init(headwordEntry: headwordEntry, saved: saved, expanded: true)
        
        $notes
            .debounce(for: .seconds(5), scheduler: DispatchQueue.main)
            .sink { [weak self] output in
                self?.saveVocabulary()
            }
            .store(in: &subscribers)
    }
    
    override func bookmarkWord() {
        super.bookmarkWord()
        if saved == .some(true) {
            saveVocabulary()
        }
    }
    
    func saveVocabulary() {
        if let vocabulary = DataManager.shared.fetchVocabularyEntry(for: headwordEntry.word) as? VocabularyEntry {
            vocabulary.notes = notes
            DataManager.shared.resaveVocabularyEntry(vocabulary)
        }
    }
    
    private static func getFamiliarity(for word: String) -> Int {
        guard let vocabulary = DataManager.shared.fetchVocabularyEntry(for: word) as? VocabularyEntry else {
            return 0
        }
        return vocabulary.recallDates?.count ?? 0
    }
    
    private static func getNotes(for word: String) -> String {
        guard let vocabulary = DataManager.shared.fetchVocabularyEntry(for: word) as? VocabularyEntry else {
            return ""
        }
        return vocabulary.notes ?? ""
    }
    
    private static func getDate(for word: String) -> Date {
        guard let vocabulary = DataManager.shared.fetchVocabularyEntry(for: word) as? VocabularyEntry else {
            return Date()
        }
        return vocabulary.date ?? Date()
    }
}
