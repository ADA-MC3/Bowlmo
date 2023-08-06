//
//  ContentView.swift
//  Bowling Game Watch App
//
//  Created by Carissa Farry Hilmi Az Zahra on 02/08/23.
//

import SwiftUI

struct ContentView: View {
    let motionManager = MotionManager()
    let workoutManager = WorkoutManager()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            
            Button {
                print("Start")
                workoutManager.startWorkout()
            } label: {
                Text("Start")
                Image(systemName: "gearshape")
            }.buttonStyle(.bordered)
            
            Button {
                print("Stop")
                workoutManager.stopWorkout()
            } label: {
                Text("Stop")
                Image(systemName: "gearshape")
            }.buttonStyle(.bordered)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
