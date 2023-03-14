//
//  ContentView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 2022-05-03.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    @StateObject var quizViewModel = QuizViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    SearchView(viewModel: viewModel.getSearchViewModel())

                    if (viewModel.fogCamera)  {
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
                    DictionaryView(viewModel: viewModel.getDictionaryViewModel(), searchOpen: $viewModel.searchOpen)
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
                        .animation(.easeInOut, value: viewModel.searchOpen)
                        .sheet(isPresented: $viewModel.isPresentingQuiz) {
                            if DataManager.shared.hasAnyVocabulary() {
                                QuizView(viewModel: QuizViewModel(), isPresenting: $viewModel.isPresentingQuiz)
                                    .background(Color.verdigris)
                            } else {
                                QuizPlaceholder()
                            }
                        }
                    
                    VStack {
                        Spacer()
                        HStack {
                            Button {
                                viewModel.openQuiz()
                            } label: {
                                HStack {
                                    Image(systemName: "star.circle.fill")
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                        .foregroundColor(.white)
                                    Text("Q U I Z")
                                        .font(.footnote.bold())
                                        .foregroundColor(.white)
                                }
                                .padding(5)
                                .padding(.horizontal, 8)
                            }
                            .buttonStyle(MenuButtonStyle(fillColor: LinearGradient(colors: [.sunglow, .gradient3], startPoint: .topLeading, endPoint: .bottomTrailing), strokeColor: .satinGold))
                            Spacer()
                            Button {
                                viewModel.openQuiz()
                            } label: {
                                Text("Q U I Z")
                                    .padding(5)
                                    .padding(.horizontal, 8)
                                    .font(.footnote.bold())
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(MenuButtonStyle(fillColor: LinearGradient(colors: [.gradient2, .gradient5], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                         strokeColor: .silverLakeBlue))
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 13)
                }
            }
        }
    }
}

struct MenuButtonStyle<Fill: View>: ButtonStyle {
    var fillColor: Fill
    var strokeColor: Color
        
    init(fillColor: Fill, strokeColor: Color) {
        self.fillColor = fillColor
        self.strokeColor = strokeColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                fillColor
            ).mask {
                RoundedRectangle(cornerRadius: 12)
            }
    }
}
