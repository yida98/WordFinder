//
//  NeumorphicButton.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/30/23.
//

import Foundation
import SwiftUI

struct NeumorphicToggleStyle<S: Shape>: ToggleStyle {
    var shape: S
    var start: Color
    var end: Color
    
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            configuration.label
                .padding(30)
                .contentShape(RoundedRectangle(cornerRadius: 20))
        }
        .background(
            NeumorphicBackground(shape: shape, start: start, end: end, pressed: configuration.isOn)
        )

    }
}

struct NeumorphicBackground<S: Shape>: View {
    var shape: S
    var start: Color
    var end: Color
    var pressed: Bool
    
    var body: some View {
        ZStack {
            if pressed {
                shape
                    .fill(LinearGradient(colors: [end, start], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(shape.stroke(LinearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 6))
//                    .shadow(color: start, radius: 10, x: 5, y: 5)
//                    .shadow(color: end, radius: 10, x: -5, y: -5)
            } else {
                shape
                    .fill(LinearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(shape.stroke(LinearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 6))
//                    .shadow(color: start, radius: 10, x: -5, y: -5)
//                    .shadow(color: end, radius: 10, x: 5, y: 5)
            }
        }
    }
}
