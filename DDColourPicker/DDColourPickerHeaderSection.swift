//
//  DDColourPickerHeaderSection.swift
//  DDColourPicker
//
//  Created by Dilraj Devgun on 3/21/20.
//  Copyright © 2020 Dilraj Devgun. All rights reserved.
//
//  A View containing both a title and a colour that is a
//  associated to that title. It is laid out where the title
//  is above the coloured circle and they are both horizontally
//  centred. The view is intended to be plced within the header
//  of the DDColourPicker
//
//
//    MIT License
//
//    Copyright (c) 2020 Dilraj Devgun
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.


import UIKit

protocol DDColourPickerHeaderSectionDelegate: class {
    
    
    /// Called when the user presses in the section header
    ///
    /// - Parameter section: a reference to the section header which the action occured on
    func didPressHeaderSection(section:DDColourPickerHeaderSection)
}

class DDColourPickerHeaderSection: UIView {

    // public fields
    var delegate:DDColourPickerHeaderSectionDelegate?       // the delegate for for which to notify of events such as a user tapping the section header
    var isSelected:Bool = false {                           // whether the current section is selected/in focus, view becomes a bit transparent if not selected
        didSet {
            if initialSetup {
                self.alpha = self.isSelected ? 1 : 0.4
            }
        }
    }

    
    // private fields
    private var circleDiameter:CGFloat = 0      // the diameter of the circle
    private var sectionText:String = ""         // title for the section
    private var sectionLabel:UILabel!           // label containing the section title
    private var colourPoint:CGPoint!            // the point at which the circle for the section is centred
    private var colourDot:UIView!               // the colour circle for the section header
    private var colour:UIColor = UIColor.blue   // the colour of the circle
    private var coverButton:UIButton!           // the button which covers the section header
    private var initialSetup:Bool = false       // whether the view has been setup
    

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
    
    
    /// setup
    ///
    /// Sets up the subviews and lays them out in the appropriate position on screen
    ///
    func setup() {
        if !initialSetup {
            
            // create label
            sectionLabel = UILabel()
            sectionLabel.text = sectionText
            sectionLabel.sizeToFit()
            sectionLabel.textAlignment = .center
            sectionLabel.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: sectionLabel.frame.height)
            self.addSubview(sectionLabel)
            
            // create circle and anchor point
            colourPoint = CGPoint(x: self.frame.width/2, y: sectionLabel.frame.maxY + 10 + circleDiameter/2)
            colourDot = UIView(frame: CGRect(x: 0, y: 0, width: circleDiameter, height: circleDiameter))
            colourDot.center = colourPoint
            colourDot.layer.cornerRadius = circleDiameter/2
            colourDot.backgroundColor = colour
            self.addSubview(colourDot)
            
            // create the button to cover the view
            coverButton = UIButton(frame: self.bounds)
            coverButton.backgroundColor = UIColor.clear
            coverButton.addTarget(self, action: #selector(self.pressedButton(sender:)), for: .touchUpInside)
            self.addSubview(coverButton)
            
            // set the alpha of the view depending on whether it is selected or not
            self.alpha = self.isSelected ? 1 : 0.4
            
            self.initialSetup = true
        }
    }
    
    
    
    /// pressedButton
    ///
    /// Callback when the user taps the button for this view and notifies the delegate that
    /// the action occured
    ///
    /// - Parameter sender: the button which triggered the action
    ///
    @objc func pressedButton(sender: UIButton) {
        self.delegate?.didPressHeaderSection(section: self)
    }
    
    
    
    /// getDotPoint
    ///
    /// getter method for the center point of where the circle lies on the section header
    ///
    func getDotPoint() -> CGPoint {
        return self.colourPoint
    }
    
    
    /// fadeDotOut
    ///
    /// fades the circle currently presented out
    ///
    func fadeDotOut() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: [.beginFromCurrentState, .curveEaseInOut], animations: {() in
            self.colourDot.transform = CGAffineTransform(scaleX: 0, y: 0)
            self.colourDot.alpha = 0
        }, completion: {(success:Bool) in
            self.colourDot.transform = CGAffineTransform.identity
        })
    }
    
    
    /// replaceColour
    ///
    /// replaces the colour of the circle in the view and makes its alpha 1
    ///
    /// - Parameter colour: the colour for which to change the circle to
    ///
    func replaceColour(colour:UIColor) {
        self.colourDot.backgroundColor = colour
        self.colourDot.alpha = 1
    }
}
