//
//  BowlingRefViewController.swift
//  Bowling Game
//
//  Created by Carissa Farry Hilmi Az Zahra on 07/08/23.
//

import UIKit
import SceneKit
import WatchConnectivity

class BowlingRefViewController: UIViewController, SessionDelegate, SCNPhysicsContactDelegate, SCNSceneRendererDelegate {
    var sessionDelegater: SessionDelegater!
    
    var sceneView: SCNView!
    var scene: SCNScene!
    var bowlingRefScene = BowlingRefScene()
    
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
    var ballRestThreshold: Float = 0.1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sessionDelegater = SessionDelegater()
        sessionDelegater.delegate = self
        
        bowlingRefScene = BowlingRefScene()
        
        // Set up Scene
        setUpScene()
        
        // Make new Scene View
        sceneView = SCNView(frame: view.bounds)
        sceneView.backgroundColor = .black
        sceneView.allowsCameraControl = true
        sceneView.scene = scene
        sceneView.delegate = self
        sceneView.scene?.physicsWorld.contactDelegate = self
        
        // allows the user to manipulate the camera
        sceneView.allowsCameraControl = true
        self.view.addSubview(sceneView)
    }
    
    func setUpScene() {
        // Create a new scene
        scene = SCNScene(named: "../art-ref.scnassets/ally.scn")
        
        let ballNodeData: NodeData = bowlingRefScene.makeBallNode(imageName: "art.scnassets/ball")
        let ballShape = SCNPhysicsShape(geometry: ballNodeData.geometry!, options: nil)
        
        // Add ball scene
        ball = ballNodeData.node
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
        
        // Use the received data to throw the ball
        throwTheBall()
    }
    
    func throwTheBall() {
        // MARK: Cara 2
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

        print("ball throwed!")
    }
    
    func normalizeVector(_ vector: SCNVector3) -> SCNVector3 {
        let length = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
        if length != 0.0 {
            return SCNVector3(vector.x / length, vector.y / length, vector.z / length)
        }
        return SCNVector3(0, 0, 0)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Reset the ball position if the ball has done moving
        if let ballPhysicsBody = ball.physicsBody, ballIsMoving {
            // Get the ball's current velocity
            let velocity = ballPhysicsBody.velocity
            let speed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y + velocity.z * velocity.z)

            // If the ball's speed is below the threshold, consider it as stopped
            if speed < ballRestThreshold {
                ballIsMoving = false
                resetTheBall()
            }
        }
        
        // Reset ball position if the ball outside the camera's field of view
        if sceneView.pointOfView != nil {
            let ballPosition = ball.presentation.position
            let projectedPosition = sceneView.projectPoint(ballPosition)
            
            // Convert CGFloat projectedPosition values to Float
            let projectedPositionX = Float(projectedPosition.x)
            let projectedPositionY = Float(projectedPosition.y)
            
            // Check if the projected position is within the screen bounds
            DispatchQueue.main.async {
                // UIView usage
                if projectedPositionX < 0 || projectedPositionX > Float(self.sceneView.bounds.size.width) ||
                    projectedPositionY < 0 || projectedPositionY > Float(self.sceneView.bounds.size.height) {
                    
                    self.resetTheBall()
                }
            }
            
        }
    }
    
    func resetTheBall() {
        ball.physicsBody?.velocity = SCNVector3(x: 0, y: 0, z: 0)
        self.ball.physicsBody?.applyForce(SCNVector3(0, 0, 0), asImpulse: true)
        ball.position = SCNVector3(x: -1.75, y: 0, z: 0) // x+: depan, y+: atas, z+: kanan
    }
}

#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct BowlingRefViewController_Preview: PreviewProvider {
    static var previews: some View {
        BowlingRefViewController().showPreview()
    }
}
#endif
