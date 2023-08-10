//
//  BowlingRefScene.swift
//  Bowling Game
//
//  Created by Carissa Farry Hilmi Az Zahra on 07/08/23.
//

import UIKit
import SceneKit

struct NodeData {
    var node: SCNNode
    var geometry: SCNGeometry?
}
class BowlingRefScene: SCNScene {
    override init () {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeBallNode(imageName: String) -> NodeData {
        let sphereGeometry = SCNSphere(radius: 0.3)
        
        // Give the ball the color from an image
        let skyboxMaterial = SCNMaterial()
        skyboxMaterial.diffuse.contents = UIImage(named: imageName)
        
        sphereGeometry.materials = [skyboxMaterial]
        
        let sphereNode = SCNNode(geometry: sphereGeometry)
        sphereNode.geometry?.firstMaterial?.isDoubleSided = true
        
        return NodeData(node: sphereNode, geometry: sphereGeometry)
    }
}
