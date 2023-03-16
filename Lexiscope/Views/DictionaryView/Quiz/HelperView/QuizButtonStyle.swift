//
//  QuizButtonStyle.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/31/23.
//

import Foundation
import SwiftUI

struct QuizButtonStyle<S: Shape>: ButtonStyle {
    var shape: S
    var primaryColor: Color
    var secondaryColor: Color
    var baseColor: Color
    var disabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        if disabled {
            configuration.label
                .font(.subheadline.bold())
                .foregroundColor(secondaryColor)
                .background(
                    shape
                        .fill(primaryColor)
                )
        } else {
            configuration.label
                .font(.subheadline.bold())
                .foregroundColor(secondaryColor)
                .offset(y: configuration.isPressed ? 0 : -7)
                .background(
                    CartoonShadowBackground(shape: shape, selectionColor: primaryColor, shadowColor: secondaryColor, buttonDefaultColor: primaryColor, baseColor: baseColor, selected: configuration.isPressed)
                )
        }
    }
}

struct QuizToggleStyle<S: Shape>: ToggleStyle {
    var shape: S
    var primaryColor: Color
    var secondaryColor: Color
    var highlight: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote)
            .onTapGesture {
                configuration.isOn.toggle()
            }
            .foregroundColor(secondaryColor)
            .padding()
            .offset(y: configuration.isOn ? 0 : -7)
            .background(
                CartoonShadowBackground(shape: shape, selectionColor: primaryColor, shadowColor: secondaryColor, buttonDefaultColor: primaryColor, baseColor: highlight, selected: configuration.isOn)
            )
            .animation(.easeOut(duration: 0.2), value: configuration.isOn)
    }
    
}

struct CartoonShadowBackground<S: Shape>: View {
    var shape: S
    var selectionColor: Color
    var shadowColor: Color
    var buttonDefaultColor: Color
    var baseColor: Color
    
    var selected: Bool
    
    var body: some View {
        ZStack {
            shape
                .fill(baseColor.opacity(0.8))
                .background(.thinMaterial)
                .clipShape(shape)
                .overlay(shape.stroke(baseColor, lineWidth: 2))
            shape
                .fill(selected ? selectionColor.opacity(0.8) : buttonDefaultColor.opacity(0.8))
                .background(.thinMaterial)
                .clipShape(shape)
                .overlay(shape.stroke(baseColor, lineWidth: 2))
                .offset(y: selected ? 0 : -7)
        }
    }
}
