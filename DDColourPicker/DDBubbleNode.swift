//
//  DDBubbleNode.swift
//  DDColourPicker
//
//  Created by Dilraj Devgun on 3/30/20.
//  Copyright © 2020 Dilraj Devgun. All rights reserved.
//

import SpriteKit


/// The bubble node for which we present in the bubble scene that have a circle body
/// and expands when selected and shrinks when not
class DDBubbleNode: SKShapeNode {
    
    open var isSelected: Bool = false {                     // whether the currently selected bubble is selected, the observer calls the shrink and expand methods appropriately
        didSet {
            guard isSelected != oldValue else { return }
            if isSelected {
                expand()
            } else {
                shrink()
            }
        }
    }
    
    public init(colour:UIColor, radius:CGFloat) {
        super.init()
        let path = SKShapeNode(circleOfRadius: radius).path!
        self.path = path
        self.fillColor = colour
        self.strokeColor = .clear
        self.physicsBody = {
            var transform = CGAffineTransform.identity.scaledBy(x: 1.01, y: 1.01)
            let body = SKPhysicsBody(polygonFrom: path.copy(using: &transform)!)
            body.allowsRotation = false
            body.friction = 0
            body.linearDamping = 1.5
            return body
        }()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    /// Expands the current node
    open func expand() {
        run(.scale(to: 1.75, duration: 0.2))
    }
    
    
    /// Shrinks the current node
    open func shrink() {
        run(.scale(to: 1, duration: 0.2))
    }
    
    
    override open func removeFromParent() {
        removedAnimation(completion: {() in
            super.removeFromParent()
        })
    }
    
    
    open func removedAnimation(completion: @escaping () -> Void) {
        run(.fadeOut(withDuration: 0.2), completion: completion)
    }
}
