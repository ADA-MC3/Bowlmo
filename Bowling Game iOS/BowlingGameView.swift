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
            )
    }
}

@available(iOS 13.0, *)
struct BowlingGameView_Previews: PreviewProvider {
    static var previews: some View {
        BowlingGameView()
    }
}
