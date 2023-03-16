//
//  Box.swift
//  Lexiscope
//
//  Created by Yida Zhang on 3/3/23.
//

import SwiftUI

struct Box<Label: View>: View {
    let label: () -> Label
    
    var body: some View {
        label()
    }
}

extension View {
    func boxStyle(_ style: some BoxStyle) -> some View {
        style.makeBody(configuration: BoxStyleConfiguration(label: BoxStyleConfiguration.Label(content: self)))
    }
}

public protocol BoxStyle {
    associatedtype Body: View
    
    func makeBody(configuration: Self.Configuration) -> Self.Body
    
    typealias Configuration = BoxStyleConfiguration
}

public struct DefaultBoxStyle: BoxStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(.ultraThinMaterial)
            .mask(roundedBackgroundView())
    }
    
    private func roundedBackgroundView() -> some Shape {
        RoundedRectangle(cornerRadius: 20)
    }
}

public struct ColouredBoxStyle: BoxStyle {
    var color: Color
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.body.bold())
            .padding()
            .background(
                roundedBackgroundView()
                    .fill(color)
                    .clipped()
            )
            .clipShape(roundedBackgroundView())
    }
    
    private func roundedBackgroundView() -> some Shape {
        RoundedRectangle(cornerRadius: 10)
    }
}

public struct BoxStyleConfiguration {
    let label: BoxStyleConfiguration.Label
    
    struct Label: View {
        init<Content: View>(content: Content) {
            body = AnyView(content)
        }
        
        var body: AnyView
    }
}
