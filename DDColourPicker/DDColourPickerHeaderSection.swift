//
//  DDColourPickerHeaderSection.swift
//  DDColourPicker
//
//  Created by Dilraj Devgun on 3/21/20.
//  Copyright © 2020 Dilraj Devgun. All rights reserved.
//

import UIKit

protocol DDColourPickerHeaderSectionDelegate: class {
    func didPressHeaderSection(section:DDColourPickerHeaderSection)
}

class DDColourPickerHeaderSection: UIView {

    // public fields
    var delegate:DDColourPickerHeaderSectionDelegate?
    var isSelected:Bool = false {
        didSet {
            if initialSetup {
                self.alpha = self.isSelected ? 1 : 0.4
            }
        }
    }

    
    // private fields
    private var circleDiameter:CGFloat = 0
    private var sectionText:String = ""
    private var sectionLabel:UILabel!
    private var colourPoint:CGPoint!
    private var colourDot:UIView!
    private var colour:UIColor = UIColor.blue
    private var coverButton:UIButton!
    private var initialSetup:Bool = false

    init(frame: CGRect, text:String, circleDiameter:CGFloat, colour:UIColor) {
        super.init(frame: frame)
        self.sectionText = text
        self.circleDiameter = circleDiameter
        self.colour = colour
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func layoutSubviews() {
        self.setup()
    }
    
    func setup() {
        if !initialSetup {
            print(sectionText)
            sectionLabel = UILabel()
            sectionLabel.text = sectionText
            sectionLabel.sizeToFit()
            sectionLabel.textAlignment = .center
            sectionLabel.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: sectionLabel.frame.height)
            self.addSubview(sectionLabel)
            
            colourPoint = CGPoint(x: self.frame.width/2, y: sectionLabel.frame.maxY + 10 + circleDiameter/2)
            colourDot = UIView(frame: CGRect(x: 0, y: 0, width: circleDiameter, height: circleDiameter))
            colourDot.center = colourPoint
            colourDot.layer.cornerRadius = circleDiameter/2
            colourDot.backgroundColor = colour
            self.addSubview(colourDot)
            
            coverButton = UIButton(frame: self.bounds)
            coverButton.backgroundColor = UIColor.clear
            coverButton.addTarget(self, action: #selector(self.pressedButton(sender:)), for: .touchUpInside)
            self.addSubview(coverButton)
            
            self.alpha = self.isSelected ? 1 : 0.4
            
            self.initialSetup = true
        }
    }
    
    
    @objc func pressedButton(sender: UIButton) {
        self.delegate?.didPressHeaderSection(section: self)
    }
    
    
    func getDotPoint() -> CGPoint {
        return self.colourPoint
    }
    
    
    func fadeDotOut() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: [.beginFromCurrentState, .curveEaseInOut], animations: {() in
            self.colourDot.transform = CGAffineTransform(scaleX: 0, y: 0)
            self.colourDot.alpha = 0
        }, completion: {(success:Bool) in
            self.colourDot.transform = CGAffineTransform.identity
        })
    }
    
    
    func replaceColour(colour:UIColor) {
        self.colourDot.backgroundColor = colour
        self.colourDot.alpha = 1
    }
}
