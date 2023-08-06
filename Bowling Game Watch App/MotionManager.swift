//
//  MotionManager.swift
//  Bowling Game iOS
//
//  Created by Carissa Farry Hilmi Az Zahra on 02/08/23.
//

import Foundation
import CoreMotion
import WatchKit
import HealthKit

class MotionManager {
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    let wristLocationIsRight = WKInterfaceDevice.current().wristLocation == .right
    
    
    // MARK: Application Specific Constants
    
    // These constants were derived from data and should be further tuned for your needs.
    let yawThreshold = 1.95 // Radians
    let rateThreshold = 5.5    // Radians/sec
    let resetThreshold = 5.5 * 0.05 // To avoid double counting on the return swing.
    
    // The app is using 50hz data and the buffer is going to hold 1s worth of data.
//    let sampleInterval = 1.0 / 50
    
    // The app is using 50hz data and the buffer is going to hold 5s worth of data.
    let sampleInterval = 5.0 / 50
    let rateAlongGravityBuffer = RunningBuffer(size: 50)
    
    /// Swing counts.
    var swingCount = 0
    
    private var startTime: TimeInterval = 0.0
    private var startAcceleration: Double = 0.0 // The start acceleration of the throw
    private var startRotationRate: Double = 0.0
    private var distance: Double = 0.0
    private var throwDirection: (x: Double, y: Double, z: Double) = (0.0, 0.0, 0.0)
    
    
    // MARK: Start Motion Manager
    func startUpdates() {
//        print("updated!")
        if !motionManager.isDeviceMotionAvailable {
            print("Device Motion is not available.")
            return
        }
        
        // Reset everything when we start.
        resetAllState()
        
        // How often we should record a measurement.
        motionManager.deviceMotionUpdateInterval = sampleInterval
        
        // Start updates and register it on queue
        motionManager.startDeviceMotionUpdates(to: queue) { (deviceMotion: CMDeviceMotion?, error: Error?) in
            if error != nil {
                print("Encountered error: \(error!)")
            }

            if deviceMotion != nil {
                self.processDeviceMotion(deviceMotion!)
            }
        }
    }
    
    // MARK: Motion Processing
    func processDeviceMotion(_ deviceMotion: CMDeviceMotion) {
//        let gravity = deviceMotion.gravity
        let rotationRate = deviceMotion.rotationRate
        let acceleration = deviceMotion.userAcceleration
        
        // Calculate the magnitude of the acceleration vector
        let accelerationMagnitude = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2))
        
        // Detect the start of the throw based on a threshold value (you may need to adjust this)
        if self.startAcceleration == 0.0 && accelerationMagnitude > 1.5 {
            startTime = deviceMotion.timestamp
            startAcceleration = accelerationMagnitude
            startRotationRate = rotationRate.z
        }
        
        // Calculate the elapsed time since the start of the throw
        let elapsedTime = deviceMotion.timestamp - self.startTime
        
        // If the throw has started, calculate the distance using a simple formula (you may need to adjust this)
        if startAcceleration > 0.0 {
            // Calculate distance using a simplified formula (you'll need to calibrate this based on real-world data)
            distance = 0.5 * startAcceleration * elapsedTime * elapsedTime
            
            // Get the direction of the throw from gyroscope data
            throwDirection = (rotationRate.x, rotationRate.y, rotationRate.z)
        }
        
        // Once the throw has ended (e.g., when acceleration drops below a threshold), stop tracking and use the calculated distance in your game logic

        // For simplicity, let's assume the throw ends when the acceleration drops below 0.1
        if (startAcceleration > 0.0) && (accelerationMagnitude < 0.1) {
            // Use 'self.distance' in your game logic (e.g., to set the ball's initial velocity in SceneKit)
            print("Throw distance: \(distance)")
            print("Throw direction: \(throwDirection)")
            
            resetAllState()
        }

        print(accelerationMagnitude)
    }
    
    
    // MARK: Data and Delegate Management
    func resetAllState() {
        rateAlongGravityBuffer.reset()

        startAcceleration = 0.0
        distance = 0.0
        throwDirection = (0.0, 0.0, 0.0)
        swingCount = 0
    }
}
