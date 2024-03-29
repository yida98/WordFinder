//
//  SectionedScrollView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/24/23.
//

import SwiftUI

struct SectionedScrollView: View {
    var sectionTitles: [String]
    @GestureState var dragLocation: CGPoint = .zero
    var scrollProxy: ScrollViewProxy
    @Binding var previousTitle: String
    
    var body: some View {
        VStack {
            ForEach(sectionTitles, id: \.self) { title in
                Text(String(title).uppercased())
                    .font(.caption)
                    .bold()
                    .frame(width: 40, height: 14)
                    .background(dragObserver(title: title))
                    .foregroundColor(.verdigris) // primary
                    .onTapGesture {
                        scroll(to: title)
                    }
            }
        }
        .highPriorityGesture(
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
            if previousTitle != title {
                scroll(to: title)
            }
        }
        return Rectangle().fill(Color.clear)
      }
    
    private func scroll(to title: String) {
        DispatchQueue.main.async {
            scrollProxy.scrollTo(title, anchor: .top)
            let impactHeptic = UIImpactFeedbackGenerator(style: .light)
            impactHeptic.impactOccurred()
            previousTitle = title
        }
    }
}
