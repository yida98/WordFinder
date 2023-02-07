//
//  QuizAnimationModifier.swift
//  Lexiscope
//
//  Created by Yida Zhang on 2/6/23.
//

import SwiftUI

struct QuizAnimationModifier<A: Equatable>: ViewModifier {
    var dataSource: [A]
    @Binding var offset: CGFloat
    @State private var counter1: Int = 0
    @State private var counter2: Int = 0
    var viewModel: QuizAnimationViewModel<A>
    
    func body(content: Content) -> some View {
        HStack(spacing: 0) {
            ForEach(dataSource.indices, id: \.self) { index in
                content
            }
            .animation(nil, value: dataSource)
            .animation(.linear, value: offset)
            .offset(x: offset)
        }
    }
}

class QuizAnimationViewModel<A: Equatable>: QuizAnimatingDelegate {
    var dataSource: [A]
    private var counter1: Int = 0
    private var counter2: Int = 0
    @Binding var offset: CGFloat
    
    init(dataSource: [A], offset: Binding<CGFloat>) {
        self.dataSource = dataSource
        self._offset = offset
    }
    
    func submit() {
        print("submitted")
        if counter1 == counter2 {
            if dataSource.count > 1 {
                dataSource.remove(at: 0)
            }
//            dataSource.append("Another \(counter1)")
            offset = CGFloat(dataSource.count - 1) * (Constant.screenBounds.width / 2)
            counter1 += 1
        } else {
            offset = CGFloat(dataSource.count - 1) * -(Constant.screenBounds.width / 2)
            counter2 += 1
        }
    }
}

extension View {
    func QuizAnimation<A: Equatable>(dataSource: [A], offset: Binding<CGFloat>) -> some View {
        let viewModel = QuizAnimationViewModel(dataSource: dataSource, offset: offset)
        return modifier(QuizAnimationModifier(dataSource: dataSource, offset: offset, viewModel: viewModel))
    }
}

protocol QuizAnimatingDelegate {
    func submit()
}
