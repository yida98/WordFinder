//
//  QuizUtilityButtonStyle.swift
//  Lexiscope
//
//  Created by Yida Zhang on 2/8/23.
//

import SwiftUI

struct QuizUtilityButtonStyle: ButtonStyle {
    var buttonColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? .white : buttonColor)
            .padding(4)
            .padding(.horizontal, 4)
            .background(configuration.isPressed ? buttonColor : .clear)
            .cornerRadius(6)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(buttonColor, lineWidth: 2)
            }
    }
}
