//
//  ProgressBar.swift
//  Lexiscope
//
//  Created by Yida Zhang on 2/8/23.
//

import SwiftUI

struct ProgressBar: View {
    var numerator: Int
    var denominator: Int
    var height: CGFloat
    private var padding: CGFloat
    private var primaryColor: Color
    private var secondaryColor: Color
    
    init(numerator: Int, denominator: Int, height: CGFloat, primaryColor: Color = .commonGreen, secondaryColor: Color = .morningDustBlue) {
        self.numerator = numerator
        self.denominator = denominator
        self.height = height
        self.padding = 4
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
    }
    
    var body: some View {
        GeometryReader { proxy in
            HStack {
                Capsule()
                    .fill(primaryColor)
                    .frame(height: height)
                if getWidth(proxy: proxy) >= 0 {
                    Spacer()
                        .frame(width: getWidth(proxy: proxy), height: height)
                }
            }
            .animation(.easeOut(duration: 0.2), value: numerator)
            .padding(padding)
            .overlay {
                Capsule()
                    .stroke(secondaryColor, lineWidth: 2)
            }
        }.frame(height: height + (padding * 2) + 1)
    }
    
    private func getWidth(proxy: GeometryProxy) -> CGFloat {
        let realSize = proxy.size.width * (CGFloat((denominator - numerator) + 1) / CGFloat(denominator))
        if numerator == 1 {
            return (proxy.size.width - height - padding * 2)
        }
        return realSize
    }
}