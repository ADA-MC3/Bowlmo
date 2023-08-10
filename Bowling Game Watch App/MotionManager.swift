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
import WatchConnectivity

class MotionManager: SessionDelegate {
    var sessionDelegater: SessionDelegater!
    
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    let wristLocationIsRight = WKInterfaceDevice.current().wristLocation == .right
    
    
    // MARK: Application Specific Constants
    
    // These constants were derived from data and should be further tuned for your needs.
    let yawThreshold = 1.95 // Radians
    let rateThreshold = 5.5    // Radians/sec
    let resetThreshold = 5.5 * 0.05 // To avoid double counting on the return swing.
    let minAccelerationMagnitude = 0.2
    
    // The app is using 50hz data and the buffer is going to hold 5s worth of data.
    let sampleInterval = 5.0 / 5.0
    let rateAlongGravityBuffer = RunningBuffer(size: 50)
    
    private var startTime: TimeInterval = 0.0
    private var startAcceleration: Double = 0.0 // The start acceleration of the throw
    private var distance: Double = 0.0
    private var throwDirection: (x: Double, y: Double, z: Double) = (0.0, 0.0, 0.0)
    
    
    // MARK: Start Motion Manager
    func startUpdates() {
        if !motionManager.isDeviceMotionAvailable {
            print("Device Motion is not available.")
            return
        }
        
        // Reset everything when we start.
        resetAllState()
        
        sessionDelegater = SessionDelegater()
        sessionDelegater.delegate = self
        
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
        let rotationRate = deviceMotion.rotationRate
        let acceleration = deviceMotion.userAcceleration
        
        // Calculate the magnitude of the acceleration vector (besar percepatan dari vektor dengan phytagoras)
        let accelerationMagnitude = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2))
        
        // Detect the start of the throw based on a threshold value
        if self.startAcceleration == 0.0 && accelerationMagnitude > minAccelerationMagnitude {
            startTime = deviceMotion.timestamp
            startAcceleration = accelerationMagnitude
        }
        
        // Calculate the elapsed time since the start of the throw
        let elapsedTime = deviceMotion.timestamp - self.startTime
        
        // If the throw has started, calculate the distance using a simple formula
        if startAcceleration > 0.0 {
            // Use the initial acceleration (startAcceleration) as a substitute for the initial velocity (v0) with the asumtion that the acceleration remains relatively constant during the entire duration of the throw
            // MARK: Formula -> d = v0.t + 1/2.a.t^2
            distance = 0.5 * startAcceleration * elapsedTime * elapsedTime
            
            // Get the direction of the throw from gyroscope data
            throwDirection = (rotationRate.x, rotationRate.y, rotationRate.z)
        }
        
        // Once the throw has ended (e.g., when acceleration drops below a threshold), stop tracking and use the calculated distance in your game logic

        // Assume the throw ends when the acceleration drops below 0.1
        if (startAcceleration > 0.0) && (accelerationMagnitude < 0.1) {
            print("Throw distance: \(distance)")
            print("Throw direction: \(throwDirection)")
            print("Acceleration Magnitude: \(accelerationMagnitude)")
            
            // Send data to iWatch
            sendDistanceAndDirectionToWatch(distance: distance, direction: throwDirection)
            
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
    }
    
    // Conform to SessionDelegate methods
    func didReceiveData(distance: Double, direction: [Double]) {
        // Handle the received data
        print("Received distance on iWatch: \(distance), direction x: \(direction[0]), direction y: \(direction[1]), direction z: \(direction[2])")
    }
    
    // Function to send distance and direction data to the paired Apple Watch
    func sendDistanceAndDirectionToWatch(distance: Double, direction: (x: Double, y: Double, z: Double)) {
        let data: [String: Any] = ["distance": distance, "direction": [direction.x, direction.y, direction.z]]
        sessionDelegater.session.sendMessage(data, replyHandler: nil, errorHandler: nil)
    }
}
