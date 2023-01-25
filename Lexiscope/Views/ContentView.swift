//
//  ContentView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 2022-05-03.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    SearchView(viewModel: viewModel.getSearchViewModel())

                    if !(viewModel.searchOpen)  {
                        Rectangle()
                            .background(.ultraThinMaterial)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.searchOpen = true
                                }
                            }
                    }
                }
                Spacer()
            }.ignoresSafeArea()
            VStack {
                Spacer()
                    .frame(height: viewModel.searchViewActiveOffset)
                    .ignoresSafeArea()
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(idealWidth: .infinity, idealHeight: .infinity)
                        .foregroundColor(.white)
                        .shadow(radius: 4)
                        .ignoresSafeArea()
                    DictionaryView()
                        .onTapGesture {
                            /// This allows the inside `ScrollView` drag gestures to co-exist with this `DragGesture`
                        }
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                                .onChanged({ dragValue in
                                    let yTouchOffset = dragValue.location.y - dragValue.startLocation.y
                                    let yMoveModifier = viewModel.offsetMoveModifier(for: yTouchOffset)
                                    let yMovement = (yTouchOffset * yMoveModifier) + viewModel.getCurrentStaticOffset()
                                    viewModel.searchViewActiveOffset = yMovement > 0 ? yMovement : 0
                                })
                                .onEnded({ dragValue in
                                    withAnimation {
                                        if viewModel.shouldToggle(dragValue.translation.height) {
                                            viewModel.searchOpen.toggle()
                                        } else {
                                            viewModel.resetOffset()
                                        }
                                    }
                                })
                        )
                }
            }
        }
    }
}
