//
//  SessionDelegater.swift
//  Bowling Game
//
//  Created by Carissa Farry Hilmi Az Zahra on 07/08/23.
//

import WatchConnectivity

protocol SessionDelegate: AnyObject {
    func didReceiveData(distance: Double, direction: [Double])
}

class SessionDelegater: NSObject, WCSessionDelegate {
    var session: WCSession!
    weak var delegate: SessionDelegate?
    
    init(session: WCSession = .default){
        super.init()
        self.session = session
        self.session.delegate = self
        
        self.session.activate()
        print("initialized nich")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        return
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
       if let distance = message["distance"] as? Double,
          let direction = message["direction"] as? [Double] {
        
           // Handle the received distance and direction data
           delegate?.didReceiveData(distance: distance, direction: direction)
       }
    }
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("\(#function): activationState = \(session.activationState.rawValue)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Activate the new session after having switched to a new watch.
        session.activate()
    }
#endif
}
