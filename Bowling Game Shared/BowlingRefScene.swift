//
//  BowlingRefScene.swift
//  Bowling Game
//
//  Created by Carissa Farry Hilmi Az Zahra on 07/08/23.
//

import UIKit
import SceneKit

class BowlingRefScene: SCNScene {
    override init () {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeBallNode(imageName: String) -> SCNNode {
        let sphereGeometry = SCNSphere(radius: 0.3)
        
        // Create a skybox material using a cube map texture
        let skyboxMaterial = SCNMaterial()
        skyboxMaterial.diffuse.contents = UIImage(named: imageName)
        
        sphereGeometry.materials = [skyboxMaterial]
        
        let sphereNode = SCNNode(geometry: sphereGeometry)
        // Flip the sphere geometry inside out (since we're viewing it from the inside)
        sphereNode.geometry?.firstMaterial?.isDoubleSided = true
        
        return sphereNode
    }
}
