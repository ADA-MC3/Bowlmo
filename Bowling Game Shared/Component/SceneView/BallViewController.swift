//
//  BallViewController.swift
//  Bowling Game
//
//  Created by Carissa Farry Hilmi Az Zahra on 06/08/23.
//

import UIKit
import SpriteKit
import GameplayKit

class BallViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sceneView = SCNView(frame: self.view.frame)
        self.view.addSubview(sceneView)

        let scene = SCNScene()
        sceneView.scene = scene

        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: -3.0, y: 3.0, z: 3.0)

        let light = SCNLight()
        light.type = SCNLight.LightType.omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 1.5, y: 1.5, z: 1.5)

        let sphereGeometry = SCNSphere(radius: 0.9)

        let sphereNode = SCNNode(geometry: sphereGeometry)

        let constraint = SCNLookAtConstraint(target: sphereNode)
        constraint.isGimbalLockEnabled = true
        cameraNode.constraints = [constraint]

        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(sphereNode)
    }
}

#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct BallViewController_Preview: PreviewProvider {
    static var previews: some View {
        BallViewController().showPreview()
    }
}
#endif
