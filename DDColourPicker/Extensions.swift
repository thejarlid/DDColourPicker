//
//  Extensions.swift
//  DDColourPicker
//
//  Created by Dilraj Devgun on 3/20/20.
//  Copyright © 2020 Dilraj Devgun. All rights reserved.
//

import UIKit

extension CGPoint {
    func distance(from point: CGPoint) -> CGFloat {
        return hypot(point.x - x, point.y - y)
    }
}

extension CGFloat {
    static func random(_ lower: CGFloat = 0, _ upper: CGFloat = 1) -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (upper - lower) + lower
    }
}
