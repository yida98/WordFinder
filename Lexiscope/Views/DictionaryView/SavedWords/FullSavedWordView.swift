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
    
    var body: some View {
        VStack(spacing: -10) {
            Rectangle()
                .fill(viewModel.familiarity >= 4 ? Color.silverLakeBlue : .gradient2a)
                .frame(height: 20)
            VStack {
                DefinitionView(viewModel: viewModel, spacing: 10, familiar: viewModel.familiarity >= 4)
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
                    viewModel.presentNotesEditor = true
                }
            }
            .padding(50)
            .background(RoundedRectangle(cornerRadius: 10).fill(.linearGradient(colors: [.gradient2a, .white], startPoint: .top, endPoint: .bottom)))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .sheet(isPresented: $viewModel.presentNotesEditor, onDismiss: {
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
    @Published var presentNotesEditor: Bool = false
        
    init(headwordEntry: MWRetrieveEntry, saved: Bool) { // Headword type
        self.notes = FullSavedWordViewModel.getNotes(for: headwordEntry)
        self.familiarity = FullSavedWordViewModel.getFamiliarity(for: headwordEntry)
        self.date = FullSavedWordViewModel.getDate(for: headwordEntry)

        super.init(headwordEntry: headwordEntry, saved: saved, expanded: true)
    }
    
    override func bookmarkWord() {
        super.bookmarkWord()
        if saved == .some(true) {
            saveVocabulary()
        }
    }
    
    func saveVocabulary() {
        if let vocabulary = DataManager.shared.fetchVocabularyEntry(for: headwordEntry){
            vocabulary.notes = notes
        }
    }
    
    private static func getFamiliarity(for headwordEntry: MWRetrieveEntry) -> Int { // Headword type
        guard let vocabulary = DataManager.shared.fetchVocabularyEntry(for: headwordEntry) else {
            return 0
        }
        return vocabulary.recallDates?.count ?? 0
    }
    
    private static func getNotes(for headwordEntry: MWRetrieveEntry) -> String { // Headword type
        guard let vocabulary = DataManager.shared.fetchVocabularyEntry(for: headwordEntry) else {
            return ""
        }
        return vocabulary.notes ?? ""
    }
    
    private static func getDate(for headwordEntry: MWRetrieveEntry) -> Date { // Headword type
        guard let vocabulary = DataManager.shared.fetchVocabularyEntry(for: headwordEntry) else {
            return Date()
        }
        return vocabulary.date ?? Date()
    }
}
