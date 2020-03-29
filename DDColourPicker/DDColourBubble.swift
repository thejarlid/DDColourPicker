//
//  DDColourBubble.swift
//  DDColourPicker
//
//  Created by Dilraj Devgun on 3/22/20.
//  Copyright © 2020 Dilraj Devgun. All rights reserved.
//

import UIKit

class DDColourBubble: UIButton {
    
    
    public init(colour:UIColor, diameter:CGFloat) {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: diameter, height: diameter)))
        let maskPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), cornerRadius: diameter/2)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
        
        self.backgroundColor = colour
        self.clipsToBounds = true
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override public var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }

    
    override public var collisionBoundingPath: UIBezierPath{
        return UIBezierPath(ovalIn: self.bounds);
    }
}
