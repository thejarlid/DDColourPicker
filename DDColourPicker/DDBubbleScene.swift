//
//  DDBubbleScene.swift
//  DDColourPicker
//
//  Created by Dilraj Devgun on 3/30/20.
//  Copyright © 2020 Dilraj Devgun. All rights reserved.
//

import SpriteKit

@objc
protocol DDBubbleSceneDelegate: class {
    func bubbleScene(_ scene: DDBubbleScene, didSelect bubble:DDBubbleNode)
}

enum DDBubbleAnimationDirection {
    case Left
    case Right
    case All
}

class DDBubbleScene: SKScene {
    
    lazy var gravity:SKFieldNode = {
        let field = SKFieldNode.radialGravityField()
        self.addChild(field)
        return field
    }()
    
    override var size: CGSize {
        didSet {
            setup()
        }
    }
    
    weak var bubbleSceneDelegate:DDBubbleSceneDelegate?
    private var selectedBubble:DDBubbleNode?
    
    
    override init(size: CGSize) {
        super.init(size: size)
        setup()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    private func setup() {
        backgroundColor = .clear
        scaleMode = .aspectFill
        
        let strength = Float(max(size.width, size.height))
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
    }
    
    
    override func addChild(_ node: SKNode) {
        let isLeft = Bool.random()
        let xPos = isLeft ? -node.frame.width : frame.width + node.frame.width
        let yPos = CGFloat.random(node.frame.height, frame.height - node.frame.height)
        node.position = CGPoint(x: xPos, y: yPos)
        super.addChild(node)
    }
    
    
    func animateBubblesIn(bubbles:[DDBubbleNode], direction:DDBubbleAnimationDirection) {
        
        let _ = children.compactMap {
            guard let bubble = $0 as? DDBubbleNode else { return }
            var exitXPos:CGFloat = 0
            if direction == .All {
                exitXPos = Bool.random() ? -bubble.frame.width : self.frame.width + bubble.frame.width
            } else {
                exitXPos = direction == .Left ? -bubble.frame.width : self.frame.width + bubble.frame.width
            }
            bubble.run(.move(to: CGPoint(x: exitXPos, y: bubble.position.y), duration: 0.4), completion: {() in
                bubble.removeFromParent()
            })
        }
        
        let _ = bubbles.compactMap {
            let bubble = $0
            var entryXPos:CGFloat = 0
            if direction == .All {
                entryXPos = Bool.random() ? -bubble.frame.width : self.frame.width + bubble.frame.width
            } else {
                entryXPos = direction == .Left ? self.frame.width + bubble.frame.width : -bubble.frame.width
            }
            let yPos = CGFloat.random(bubble.frame.height, self.frame.height - bubble.frame.height)
            bubble.position = CGPoint(x: entryXPos, y: yPos)
            super.addChild(bubble)
        }
    }
    
    
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
