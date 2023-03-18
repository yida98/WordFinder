//
//  QuizOptionCell.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/30/23.
//

import SwiftUI

struct QuizOptionCell: View {
    var text: String
    var id: Int
    @Binding var choice: Int?
    var validation: [Bool]?
    
    var body: some View {
        let binding = Binding<Bool>(get: { id == choice || validation != nil }, set: { _ in choice = id } )
        Toggle(isOn: binding) {
            Text(text)
                .font(.bodyQuiz)
        }
        .toggleStyle(QuizToggleStyle(shape: RoundedRectangle(cornerRadius: 16),
                                     primaryColor: getPrimaryColor(),
                                     secondaryColor: getSecondaryColor(),
                                     highlight: getHighlightColor()))
        .allowsHitTesting(validation == nil)
    }
    
    /// fill
    private func getPrimaryColor() -> Color {
        guard let validation = validation else { return .verdigrisLight }
        if choice == id {
            return validation[id] ? .commonGreen : .red
        }
        if validation[id] {
            return .honeydew
        } else {
            return .timberWolf
        }
    }
    
    private func getSecondaryColor() -> Color {
        guard let validation = validation else { return .verdigrisDark }
        if choice == id {
            return .verdigrisLight
        }
        return validation[id] ? .pineGreen : .redwood
    }
    
    private func getHighlightColor() -> Color {
        guard let validation = validation else { return .verdigrisDark }
        return validation[id] ? .pineGreen : .redwood
    }
}
