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
    
    init(numerator: Int, denominator: Int, height: CGFloat) {
        self.numerator = numerator
        self.denominator = denominator
        self.height = height
        self.padding = 4
    }
    
    var body: some View {
        GeometryReader { proxy in
            HStack {
                Capsule()
                    .fill(Color.commonGreen)
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
                    .stroke(Color.morningDustBlue, lineWidth: 2)
            }
        }
    }
    
    private func getWidth(proxy: GeometryProxy) -> CGFloat {
        let realSize = proxy.size.width * (CGFloat((denominator - numerator) + 1) / CGFloat(denominator))
        if numerator == 1 {
            return (proxy.size.width - height - padding * 2)
        }
        return realSize
    }
}
