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
    
    func makeBallNode() -> SCNNode {
        let sphereGeometry = SCNSphere(radius: 0.9)
        let sphereNode = SCNNode(geometry: sphereGeometry)
        
        return sphereNode
    }
}
