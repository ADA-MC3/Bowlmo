//
//  BowlingRefViewController.swift
//  Bowling Game
//
//  Created by Carissa Farry Hilmi Az Zahra on 07/08/23.
//

import UIKit
import SceneKit

class BowlingRefViewController: UIViewController {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bowlingRefScene = BowlingRefScene()
        
        // Set up Scene
        setUpScene()
        
        // Make new Scene View
        let sceneView = SCNView(frame: view.bounds)
        sceneView.backgroundColor = .black
        sceneView.allowsCameraControl = true
        sceneView.scene = scene
        
        // allows the user to manipulate the camera
        sceneView.allowsCameraControl = true
        self.view.addSubview(sceneView)
        
    }
    
    func setUpScene() {
        // Create a new scene
        scene = SCNScene(named: "../art-ref.scnassets/ally.scn")
        
        // Add ball scene
        ball = bowlingRefScene.makeBallNode(imageName: "art.scnassets/ball")
        ball.position = SCNVector3(x: 0, y: 0.3, z: 12)
        scene.rootNode.addChildNode(ball)
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
