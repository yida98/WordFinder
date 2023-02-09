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
            .font(.caption.bold())
            .foregroundColor(configuration.isPressed ? .white : buttonColor)
            .padding(6)
            .padding(.horizontal, 4)
            .background(configuration.isPressed ? buttonColor : .white)
            .cornerRadius(8)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(buttonColor, lineWidth: 2)
            }
    }
}
