//
//  ProgressBar.swift
//  Lexiscope
//
//  Created by Yida Zhang on 2/8/23.
//

import SwiftUI

struct ProgressBar: View {
    var progression: CGFloat
    var body: some View {
        ProgressView(value: progression)
    }
}

extension ProgressBar {
    func progressBarStyle(_ style: some ProgressBarStyle, fillColor: Color) -> some View {
        style.makeBody(configuration: ProgressBarConfiguration(label: ProgressBarConfiguration.Label(content: self),
                                                               progression: self.progression,
                                                               fillColor: fillColor))
    }
}

public protocol ProgressBarStyle {
    associatedtype Body: View
    typealias Configuration = ProgressBarConfiguration
    
    func makeBody(configuration: Self.Configuration) -> Self.Body
}

public struct ProgressBarConfiguration {
    let label: ProgressBarConfiguration.Label
    var progression: CGFloat
    let fillColor: Color
    
    public struct Label: View {
        init(content: any View) {
            self.body = AnyView(content)
        }
        public var body: AnyView
    }
}

public struct DefaultProgressBarStyle: ProgressBarStyle {
    public func makeBody(configuration: Configuration) -> some View {
        
        func getSpacerWidth(from proxy: GeometryProxy) -> CGFloat {
            let widthRatio = (1 - configuration.progression)
            if widthRatio == 1 {
                return proxy.size.width - proxy.size.height
            } else if widthRatio == 0 {
                return 0
            }
            return widthRatio * proxy.size.width
        }
        
        return GeometryReader { proxy in
            ZStack {
                Capsule(style: .continuous)
                    .fill(configuration.fillColor.opacity(0.3))
                HStack {
                    Capsule(style: .continuous)
                        .fill(configuration.fillColor)
                    if getSpacerWidth(from: proxy) > 0 {
                        Spacer()
                            .frame(width: getSpacerWidth(from: proxy))
                    }
                }
            }
        }
    }
}

public struct BorderedProgressBarStyle: ProgressBarStyle {
    public func makeBody(configuration: Configuration) -> some View {
        func getSpacerWidth(from proxy: GeometryProxy) -> CGFloat {
            let widthRatio = (1 - configuration.progression)
            if widthRatio == 1 {
                return 0
            } else if widthRatio == 0 {
                return proxy.size.width - proxy.size.height
            }
            return widthRatio * proxy.size.width
        }
        
        return VStack {
            GeometryReader { proxy in
                HStack {
                    Capsule(style: .continuous)
                        .fill(configuration.fillColor)
                    if getSpacerWidth(from: proxy) > 0 {
                        Spacer()
                            .frame(width: getSpacerWidth(from: proxy))
                    }
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background(
            Capsule(style: .continuous)
                .stroke(configuration.fillColor, style: StrokeStyle(lineWidth: 3))
        )
    }
}
