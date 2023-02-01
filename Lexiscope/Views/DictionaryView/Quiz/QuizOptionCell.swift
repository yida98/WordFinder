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
    var body: some View {
        let binding = Binding<Bool>(get: { id == choice }, set: { _ in choice = id } )
        Toggle(isOn: binding) {
            Text(text)
        }
        .toggleStyle(QuizToggleStyle(shape: RoundedRectangle(cornerRadius: 20), primaryColor: .magnolia, secondaryColor: .lavendarGray))
    }
}
