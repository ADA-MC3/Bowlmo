//
//  WorkoutManager.swift
//  Bowling Game Watch App
//
//  Created by Carissa Farry Hilmi Az Zahra on 02/08/23.
//

import Foundation
import HealthKit

class WorkoutManager {
    // MARK: Properties
    let motionManager = MotionManager()
    let healthStore = HKHealthStore()
    
    var session: HKWorkoutSession?
    
    func startWorkout() {
        // If we have already started the workout, then do nothing.
        if (session != nil) {
            return
        }
        
        // Configure the workout session.
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .tennis
        workoutConfiguration.locationType = .outdoor
        
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: workoutConfiguration)
        } catch {
            fatalError("Unable to create the workout session!")
        }
        
        // Start the workout session and device motion updates.
        session!.startActivity(with: Date())
        motionManager.startUpdates()
    }
    
    func stopWorkout() {
        // If the workout session is already stopped, then do nothing.
        guard let session = session, session.state != .ended else {
            return
        }

        // Stop the workout session.
        session.end()
        self.session = nil

        motionManager.sendStartTheGame(startGame: false)
        // Stop device motion updates.
        motionManager.motionManager.stopDeviceMotionUpdates()
    }
}
