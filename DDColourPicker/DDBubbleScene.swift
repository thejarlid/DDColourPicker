//
//  DDBubbleScene.swift
//  DDColourPicker
//
//  Created by Dilraj Devgun on 3/30/20.
//  Copyright © 2020 Dilraj Devgun. All rights reserved.
//

import SpriteKit

/// Interface for the DDBubbleSceneDelegate for which to notify about events
/// such as the selection of a bubble
@objc protocol DDBubbleSceneDelegate: class {
    func bubbleScene(_ scene: DDBubbleScene, didSelect bubble:DDBubbleNode)
}


/// Direction of which to animate the incoming bubbles towards
enum DDBubbleAnimationDirection {
    case Left
    case Right
    case All
}


/// The SKScene representing the gravity field that the bubbles are
/// added to and float around within
class DDBubbleScene: SKScene {
    
    lazy var gravity:SKFieldNode = {                        // the gravity field that attracts the bubble
        let field = SKFieldNode.radialGravityField()
        self.addChild(field)
        return field
    }()
    
    lazy var vortex:SKFieldNode = {
        let field = SKFieldNode.vortexField()
        self.addChild(field)
        return field
    }()
    
    override var size: CGSize {                             // property observer for the size field to call the setup method upon setting it
        didSet {
            setup()
        }
    }
    
    weak var bubbleSceneDelegate:DDBubbleSceneDelegate?     // the delegate for which to notify of events
    private var selectedBubble:DDBubbleNode?                // the currently selected bubble
    
    
    override init(size: CGSize) {
        super.init(size: size)
        setup()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    
    /// Sets up the gravity and physics properties for the
    /// current scene
    private func setup() {
        backgroundColor = .clear
        scaleMode = .aspectFill
        
        let strength = Float(max(size.width, size.height)) * 100
        let radius = strength.squareRoot() * 100
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsBody = SKPhysicsBody(edgeLoopFrom: { () -> CGRect in
            var frame = self.frame
            frame.size.width = CGFloat(radius)
            frame.origin.x -= frame.size.width / 2
            return frame
        }())
        
        gravity.region = SKRegion(radius: radius)
        gravity.minimumRadius = radius
        gravity.strength = strength
        gravity.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gravity.speed = 5
        
        vortex.region = SKRegion(radius: radius)
        vortex.minimumRadius = radius
        vortex.strength = 0.0005
        vortex.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    
    /// adds a child bubble at a random position to the left or right of the scene
    /// and lets the gravity then pull it in
    ///
    /// - Parameter node: the node to which add to the current scene
    override func addChild(_ node: SKNode) {
        let isLeft = Bool.random()
        let xPos = isLeft ? -node.frame.width : frame.width + node.frame.width
        let yPos = CGFloat.random(node.frame.height, frame.height - node.frame.height)
        node.position = CGPoint(x: xPos, y: yPos)
        super.addChild(node)
    }
    
    
    /// Animates the current set of bubbles on the screen if they exist off in the direction provided
    /// and adds the incoming nodes on the opposite side to the scene so that gravity can then pull them in
    ///
    /// - Parameters:
    ///   - bubbles: the bubbles for which to add to the scene
    ///   - direction: the direction in which to animate the new bubbles towards and clear the existing bubbles from
    ///   - shouldFade: whether the incoming bubbles should fade in
    func animateBubblesIn(bubbles:[DDBubbleNode], direction:DDBubbleAnimationDirection, shouldFade:Bool) {
        
        // remove the old bubbles on the screen
        let _ = children.compactMap {
            guard let bubble = $0 as? DDBubbleNode else { return }
            var exitXPos:CGFloat = 0
            if direction == .All {
                exitXPos = Bool.random() ? -bubble.frame.width : self.frame.width + bubble.frame.width
            } else {
                exitXPos = direction == .Left ? -bubble.frame.width : self.frame.width + bubble.frame.width
            }
            let actions = [SKAction.move(to: CGPoint(x: exitXPos, y: bubble.position.y), duration: 0.5),
                           SKAction.fadeOut(withDuration: 0.5),
                           SKAction.scale(to: 0.3, duration: 0.5)]
            let groupAction = SKAction.group(actions)
            bubble.run(groupAction, completion: {() in
                bubble.removeFromParent()
            })
        }
        self.selectedBubble = nil
        
        // add the new incoming bubbles in
        let _ = bubbles.compactMap {
            let bubble = $0
            
            // set up initial scale and alpha if fading in
            if shouldFade {
                bubble.alpha = 0
                bubble.setScale(0.3)
            }
            
            // if the current bubble is selected the scene's currently selected bubble needs to be set
            if bubble.isSelected {
                self.selectedBubble = bubble
            }
            
            // pick a random position on the side for which we are adding the bubbles to
            var entryXPos:CGFloat = 0
            if direction == .All {
                entryXPos = Bool.random() ? -bubble.frame.width : self.frame.width + bubble.frame.width
            } else {
                entryXPos = direction == .Left ? self.frame.width + bubble.frame.width : -bubble.frame.width
            }
            let yPos = CGFloat.random(bubble.frame.height, self.frame.height - bubble.frame.height)
            bubble.position = CGPoint(x: entryXPos, y: yPos)
            super.addChild(bubble)
            
            // animate the fade in if we are doing it
            if shouldFade {
                let actions = [SKAction.fadeIn(withDuration: 0.7),
                               SKAction.scale(to: 1, duration: 0.7)]
                let groupAction = SKAction.group(actions)
                bubble.run(groupAction)
            }
        }
    }
    
    
    
    /// Gets the bubble touched at a given point
    ///
    /// - Parameter point: the point for which to get bubbles at
    /// - Returns: a bubble if one exists
    private func bubble(at point: CGPoint) -> DDBubbleNode? {
        // get all the nodes that intersect at a given point
        // and for each check if their path contains the point
        // touched and return the first for which there is a match
        return nodes(at: point).compactMap {
            $0 as? DDBubbleNode
        }.filter {
            $0.path!.contains(convert(point, to: $0))
        }.first
    }
    
    
    
    /// handler for when touches end so that we can perform actions when the user taps on the screen and
    /// select a bubble if tapped on one
    ///
    /// - Parameters:
    ///   - touches: the touches which eneded
    ///   - event: the event which occured
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        guard let bubble = bubble(at: location) else { return }
        
        // unable to unselect bubble one bubble should always be selected
        // and unselecting a bubble is the job of a new bubble to replace it
        if !bubble.isSelected {
            selectedBubble?.isSelected = false
            bubble.isSelected = true
            selectedBubble = bubble
            bubbleSceneDelegate?.bubbleScene(self, didSelect: bubble)
        }
    }
}
