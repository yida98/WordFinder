//
//  AlertView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 7/6/22.
//

import Foundation
import SwiftUI

struct AlertView<Content: View>: View {
    
    let message: String
    let content: Content
    let isPresenting: Bool
    @State private var offset: CGFloat = -50
    
    init(isPresenting: Bool,
         message: String = "",
         @ViewBuilder content: () -> Content = { EmptyView() as! Content } ) {
        self.message = message
        self.content = content()
        self.isPresenting = isPresenting
    }
    
    var body: some View {
        if isPresenting {
            GeometryReader { geometry in
                VStack(alignment:.center) {
                    HStack(alignment: .center) {
                        VStack(alignment: .center, spacing: 10) {
                            if !message.isEmpty {
                                Text(message)
                                    .foregroundColor(Color.gray)
                                    .font(.caption)
                            }
                            content
                        }.padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .clipShape(
                            RoundedRectangle(cornerRadius: geometry.size.height/2)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 10, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/)
                    }.frame(minWidth: Constant.screenBounds.width)
                }.offset(y: offset)
                .onAppear(perform: {
                    offset = 0
                })
                .animation(.easeOut(duration: 0.2))
            }
        }
    }
}
struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView(isPresenting: true, message: "This is a message") {
            
        }
    }
}
