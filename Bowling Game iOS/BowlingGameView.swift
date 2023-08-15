//
//  BowlingGameView.swift
//  Bowling Game iOS
//
//  Created by Carissa Farry Hilmi Az Zahra on 14/08/23.
//

import SwiftUI

struct BowlingGameView: View {
    @StateObject var bowlingController = BowlingViewController()
    
    var body: some View {
        bowlingController
            .showPreview()
            .ignoresSafeArea()
            .overlay(
                ZStack {
                    if self.bowlingController.showStartLabel {
                        Text("Click the start button on the Watch app to begin the game.")
                            .foregroundColor(.black)
                            .font(.headline)
                            .padding(.all, 10)
                            .background(.white.opacity(0.5))
                            .cornerRadius(10)
                    }
                    
                    if self.bowlingController.showScore {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 200, height: 90)
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding(.all, 10)
                            .overlay(
                                VStack {
                                    Text("Your Score: \(self.bowlingController.score)")
                                    Button(action: {
                                        self.bowlingController.showScore = false
                                        self.bowlingController.objectWillChange.send()
                                    }) {
                                        Text("Start Again")
                                            .foregroundColor(.white)
                                            .padding(.all, 10)
                                            .background(.gray)
                                            .cornerRadius(10)
                                    }
                                }
                            )
                    }
                    
                    if !self.bowlingController.showStartLabel && !self.bowlingController.showScore {
                        VStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 200, height: 30)
                                .foregroundColor(.white)
                                .overlay(
                                    Text("Score: \(self.bowlingController.score)")
                                        .foregroundColor(.black)
                                        .font(.headline)
                                )
                            Spacer()
                        }
                    }
                }
            )
    }
}

@available(iOS 13.0, *)
struct BowlingGameView_Previews: PreviewProvider {
    static var previews: some View {
        BowlingGameView()
    }
}
