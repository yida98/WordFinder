//
//  FullSavedWordView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/30/23.
//

import SwiftUI

struct FullSavedWordView: View {
    @ObservedObject var viewModel: DefinitionViewModel
    @State private var textEditorText: String = ""
    
    var body: some View {
        Group {
            VStack {
                DefinitionView(viewModel: viewModel, spacing: 10)
                HStack {
                    Text("Familiarity:")
                        .fullSavedWordSectionTitle()
                    Circle()
                        .stamp(validation: true)
                        .frame(width: 8, height: 8)
                    Circle()
                        .stamp(validation: true)
                        .frame(width: 8, height: 8)
                    Circle()
                        .stamp(validation: false)
                        .frame(width: 8, height: 8)
                    Star(cornerRadius: 0.5)
                        .stamp(validation: false)
                        .frame(width: 12, height: 12)
                    Spacer()
                    HStack {
                        Text("Added:")
                            .fullSavedWordSectionTitle()
                        Text("2023-02-04")
                            .font(.caption)
                            .foregroundColor(.verdigris)
                    }
                    Spacer()
                }
                VStack {
                    Group {
                        if true {
                            Text("Click to edit")
                                .font(.subheadline)
                                .italic()
                                .foregroundColor(.gray.opacity(0.3))
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                        } else {
                            Text("blue blue blue")
                                .font(.subheadline)
                                .foregroundColor(.verdigrisDark)
                                .frame(maxWidth: .infinity, maxHeight: Constant.screenBounds.height / 7, alignment: .topLeading)
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
                }
            }
            .padding(50)
        }
        .ignoresSafeArea()
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
