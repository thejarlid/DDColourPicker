//
//  DDBubbleView.swift
//  DDColourPicker
//
//  Created by Dilraj Devgun on 3/30/20.
//  Copyright © 2020 Dilraj Devgun. All rights reserved.
//

import SpriteKit


/// The SKView which presents the bubble scene
class DDBubbleView: SKView {
    
    public lazy var bubbleScene: DDBubbleScene = {              // the bubble scene that is on this view
        let scene = DDBubbleScene(size: self.bounds.size)
        self.presentScene(scene)
        return scene
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        _ = bubbleScene
        self.backgroundColor = UIColor.clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bubbleScene.size = bounds.size
    }
}
