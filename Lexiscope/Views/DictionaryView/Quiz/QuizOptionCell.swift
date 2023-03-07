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
        }
        .toggleStyle(QuizToggleStyle(shape: RoundedRectangle(cornerRadius: 16),
                                     primaryColor: getPrimaryColor(),
                                     secondaryColor: getSecondaryColor(),
                                     highlight: getHighlightColor()))
        .allowsHitTesting(validation == nil)
    }
    
    /// fill
    private func getPrimaryColor() -> Color {
        guard let validation = validation else { return .magnolia }
        if choice == id {
            return validation[id] ? .yellowGreenCrayola : .red
        }
        return .white
    }
    
    private func getSecondaryColor() -> Color {
        guard let validation = validation else { return .lavendarGray }
        if choice == id {
            return .white
        }
        return validation[id] ? .darkSeaGreen : .red
    }
    
    private func getHighlightColor() -> Color {
        guard let validation = validation else { return .lavendarGray }
        return validation[id] ? .darkSeaGreen : .red
    }
}
