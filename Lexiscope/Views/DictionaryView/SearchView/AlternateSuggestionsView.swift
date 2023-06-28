//
//  AlternateSuggestionsView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 6/28/23.
//

import SwiftUI

struct AlternateSuggestionsView: View {
    @ObservedObject var viewModel: AlternateSuggestionsViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Did you mean:")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                Spacer()
            }
            ScrollView(showsIndicators: false) {
                HStack {
                    VStack {
                        ForEach(0..<columnCount(left: true), id: \.self) { index in
                            Text(viewModel.suggestions[index * 2])
                                .suggestionCell()
                                .onTapGesture {
                                    viewModel.handleTap(at: index * 2)
                                }
                        }
                        Spacer()
                    }
                    Spacer()
                    VStack {
                        ForEach(0..<columnCount(left: false), id: \.self) { index in
                            Text(viewModel.suggestions[(index * 2) + 1])
                                .suggestionCell()
                                .onTapGesture {
                                    viewModel.handleTap(at: (index * 2) + 1)
                                }
                        }
                        Spacer()
                    }
                }
            }
        }
    }
    
    private func columnCount(left: Bool) -> Int {
        viewModel.suggestions.count.isMultiple(of: 2) ? Int(viewModel.suggestions.count / 2) : Int((viewModel.suggestions.count + (left ? 1 : (-1))) / 2)
    }
}

struct AlternateSuggestionCell: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(8)
            .padding(.horizontal, 2)
            .foregroundColor(.silverLakeBlue)
            .background {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.white.opacity(0.5))
            }
    }
}

extension View {
    func suggestionCell() -> some View {
        modifier(AlternateSuggestionCell())
    }
}
