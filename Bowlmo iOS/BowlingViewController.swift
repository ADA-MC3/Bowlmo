//
//  BowlingViewController.swift
//  Bowling Game
//
//  Created by Carissa Farry Hilmi Az Zahra on 07/08/23.
//

import UIKit
import SceneKit
import WatchConnectivity

class BowlingViewController: UIViewController, SessionDelegate, SCNPhysicsContactDelegate, SCNSceneRendererDelegate, ObservableObject {
    var sessionDelegater: SessionDelegater!
    
    var sceneView: SCNView!
    var scene: SCNScene!
    var bowlingScene: BowlingScene!
    
    var camera: SCNNode!
    var ball: SCNNode!
    var pins: SCNNode!
    var cleaner: SCNNode!
    var placer: SCNNode!
    var strikeText: SCNNode!
    var spareText: SCNNode!
    var hitHappened: SCNNode!
    let sunNode = SCNNode()
    
    var throwingData: ThrowingData!
    
    let bowlingBallMass: CGFloat = 4.5  // in kg
    let forceScaleFactor: Float = 150.0 // allows to scale the forceMagnitude to a value that feels right within the context of the game
    
    var ballIsMoving = false
    var ballRestThreshold: Float = 0.01
    var countScore = false
    @Published var score = 0
    
    var showStartLabel = true
    var showScore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sessionDelegater = SessionDelegater()
        sessionDelegater.delegate = self
        
        bowlingScene = BowlingScene()
        
        // Set up Scene
        setUpScene()
        
        // Make new Scene View
        sceneView = SCNView(frame: view.bounds)
        sceneView.backgroundColor = .black
        sceneView.allowsCameraControl = false
        sceneView.scene = scene
        sceneView.delegate = self
        sceneView.scene?.physicsWorld.contactDelegate = self
        
        // allows the user to manipulate the camera
        sceneView.allowsCameraControl = true
        self.view.addSubview(sceneView)
    }
    
    func setUpScene() {
        // Create a new scene
        scene = SCNScene(named: "art.scnassets/ally.scn")
        
        camera = scene.rootNode.childNode(withName: "mainCamera", recursively: true)!
        pins = scene.rootNode.childNode(withName: "mainPins", recursively: true)!
        
        let ballNodeData: NodeData = bowlingScene!.makeBallNode(imageName: "art.scnassets/ball")
        let ballShape = SCNPhysicsShape(geometry: ballNodeData.geometry!, options: nil)
        
        // Add ball scene
        ball = ballNodeData.node
        ball.name = "Ball"
        ball.physicsBody = SCNPhysicsBody(type: .dynamic, shape: ballShape)
        ball.physicsBody?.isAffectedByGravity = true
        ball.physicsBody?.velocity = SCNVector3(x: 0, y: 0, z: 0)
        ball.physicsBody?.angularVelocity = SCNVector4(x: 0, y: 0, z: 0, w: 0)
        ball.physicsBody?.mass = bowlingBallMass
        ball.physicsBody?.friction = 0.05
        ball.physicsBody?.restitution = 0.5
        ball.physicsBody?.rollingFriction = 0.05
        ball.physicsBody?.damping = 0.1
        ball.physicsBody?.angularDamping = 0.1
        ball.physicsBody?.allowsResting = true
        ball.position = SCNVector3(x: -1.75, y: 0, z: 0) // x+: depan, y+: atas, z+: kanan
        
        scene.rootNode.addChildNode(ball)
        
        sunNode.light = SCNLight()
        sunNode.light?.type = .directional

        scene.rootNode.addChildNode(sunNode)
        
        resetCamera()
    }
    
    func didReceiveStartStatus(startGame: Bool) {
        DispatchQueue.main.async {
            self.showStartLabel = !startGame
            self.objectWillChange.send()
            print("Game status updated:")
            print(self.showStartLabel)
        }
    }
    
    // Conform to SessionDelegate methods
    func didReceiveData(distance: Double, direction: [Double]) {
        // Handle the received data
        print("Received distance on iOS: \(distance), direction x: \(direction[0]), direction y: \(direction[1]), direction z: \(direction[2])")
        
        var newDirection = direction
        
        if Float(direction[0]) > 0.0 {
            newDirection[0] = -1 * direction[0]
            print("change direction x")
        }
        
        if Float(direction[1]) < 0.0 {
            newDirection[1] = -1 * direction[1]
            print("change direction x")
        }
        
        throwingData = ThrowingData(
            distance: Float(distance),
            direction_x: (Float(newDirection[0])),  // x+: depan, y+: atas, z+: kanan
            direction_y: Float(newDirection[1]),
            direction_z: (Float(newDirection[2]))
        )
        print(throwingData!)
        
        if !showScore && !showStartLabel {
            // Use the received data to throw the ball
            throwTheBall()
        }
    }
    
    func throwTheBall() {
        let direction = SCNVector3(
            x: throwingData.direction_x,
            y: throwingData.direction_y,
            z: throwingData.direction_z
        )
        let normalizedDirection = normalizeVector(direction)
        
        // Calculate the magnitude of the force (how strong the throw is) based on the distance
        let forceMagnitude = Float(throwingData.distance) * forceScaleFactor
        
        // Force: A vector that describes how much force was applied in each dimension. The force is measured in Newtons
        let force = SCNVector3(
            x: normalizedDirection.y * forceMagnitude,
            y: normalizedDirection.x * forceMagnitude,
            z: normalizedDirection.z * forceMagnitude
        )
        
        // Apply the force to the ball's physics body
        ball!.physicsBody?.applyForce(force, asImpulse: true)
        ballIsMoving = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 13) {
            self.slowTheBall()
        }
        
        // Schedule the ball reset after 10 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            self.ballIsMoving = false
            self.score = 0
            self.resetTheBall()
            self.resetCamera()
            self.resetPins()
        }

        print("ball throwed!")
    }
    
    func normalizeVector(_ vector: SCNVector3) -> SCNVector3 {
        let length = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
        if length != 0.0 {
            return SCNVector3(vector.x / length, vector.y / length, vector.z / length)
        }
        return SCNVector3(0, 0, 0)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        let velocity = ball.physicsBody!.velocity
        let speed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y + velocity.z * velocity.z)
        
        print("Ball position:")
        print(ball.presentation.position.x)
        print("Ball speed:")
        print(speed)
        
        if (ball.position.x > -0.5 || ball.presentation.position.x > 0.5) && (ball.presentation.position.x < 33) {
            if ballIsMoving && !showScore {
                // If the ball moves forward (x+ axis, ball forward)
                if speed > ballRestThreshold {
                    camera.look(at: ball.presentation.position)
                    let ballOffset = ball.presentation.position.x
                    if ballOffset > 6 {
                        // Camera follows the ball (z- axis, camera forward)
                        camera.position.z = (-1) * (ballOffset - 8) // the distance between the camera and the ball from behind the ball
                    }
                } else { // If the ball's speed is below the threshold, consider it as stopped
                    DispatchQueue.main.async {
                        self.ballIsMoving = false
                        self.showScore = true // Show the score after the ball stopped
                        self.objectWillChange.send()
                        self.slowTheBall()
                    }
                    
                    // Schedule the ball reset after damping has taken effect
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.resetTheBall()
                        self.resetCamera()
                        self.resetPins()
                    }
                }
            }
        } else {
            // Reset the ball if the ball exit the arena
            if ball.presentation.position.x > 34 {
                ballIsMoving = false
                resetTheBall()
                resetCamera()
            }
            if !showStartLabel {
                print("No ball physics")
            }
        }
    }
    
    // Add event if there is collision between ball and the pins to count the score
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if ballIsMoving {
            if contact.nodeA.name == "Ball" || contact.nodeB.name == "Pin" {
                DispatchQueue.main.async {
                    self.score += 1
                    print("Score:")
                    print(self.score)
                }
                
            } else if contact.nodeA.name == "Pin" && contact.nodeB.name == "Ball"{
                DispatchQueue.main.async {
                    self.score += 1
                    print("Score:")
                    print(self.score)
                }
            }
        }
    }
    
    func resetPins() {
        (pins as! SCNReferenceNode).unload()
        (pins as! SCNReferenceNode).load()
    }
    
    func resetTheBall() {
        ball.physicsBody?.velocity = SCNVector3(x: 0, y: 0, z: 0)
        self.ball.physicsBody?.applyForce(SCNVector3(0, 0, 0), asImpulse: true)
        ball.position = SCNVector3(x: -1.75, y: 0, z: 0) // x+: forward, y+: top, z+: right
        
        // Reset damping values
        ball.physicsBody?.angularDamping = 0.1
        ball.physicsBody?.damping = 0.1
        print("Reset ball position.")
    }
    
    func slowTheBall() {
        // Gradually bring the ball to a complete stop using damping
        ball.physicsBody?.angularDamping = 1.0 // Apply angular damping to stop rotation
        ball.physicsBody?.damping = 1.0 // Apply linear damping to stop translation
    }
    
    func resetCamera() {
        camera.position = SCNVector3(x: 0, y: 3, z: 6) // z-: forward, y+: top, x+: right
        camera.eulerAngles = SCNVector3(x: -0.34906608, y: 1.8424535e-14, z: 1.1805374e-07)
    }
}

#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct BowlingViewController_Preview: PreviewProvider {
    static var previews: some View {
        BowlingViewController().showPreview().ignoresSafeArea()
    }
}
#endif
