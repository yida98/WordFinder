//
//  SectionedScrollView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/24/23.
//

import SwiftUI

struct SectionedScrollView: View {
    @ObservedObject var viewModel: SavedWordsViewModel
    var sectionTitles: [String]
    @GestureState var dragLocation: CGPoint = .zero
    var scrollProxy: ScrollViewProxy
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(sectionTitles, id: \.self) { title in
                Text(String(title).uppercased())
                    .font(.caption)
                    .bold()
                    .background(dragObserver(title: title))
            }
        }.padding()
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .updating($dragLocation, body: { value, state, transaction in
                        state = value.location
                    })
            )
    }
    
    func dragObserver(title: String) -> some View {
        GeometryReader { geometry in
            dragObserver(geometry: geometry, title: title)
        }
    }
    
    private func dragObserver(geometry: GeometryProxy, title: String) -> some View {
        if geometry.frame(in: .global).contains(dragLocation) {
            if viewModel.previousTitle != title {
                DispatchQueue.main.async {
                    scrollProxy.scrollTo(title, anchor: .top)
                    let impactHeptic = UIImpactFeedbackGenerator(style: .medium)
                    impactHeptic.impactOccurred()
                    viewModel.previousTitle = title
                }
            }
        }
        return Rectangle().fill(Color.clear)
      }
}
