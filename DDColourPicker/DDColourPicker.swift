//
//  DDColourPicker.swift
//  DDColourPicker
//
//  Created by Dilraj Devgun on 3/20/20.
//  Copyright © 2020 Dilraj Devgun. All rights reserved.
//
//  A view which presents various sections and colours
//  that can be picked and associated to each category.
//  The user can select the section and then pick the colour
//  which they would like to associate a colour to.
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

protocol DDColourPickerDelegate: class {
    
    /// Notifies the delegate of a colour selection that occured in the view
    ///
    /// - Parameters:
    ///   - colourPicker: a reference to the colour picker in which the selection occured
    ///   - colour: the colour the user selected
    ///   - section: the section which the user selected the colour in
    func colourPicker(_ colourPicker:DDColourPicker, didSelectColour colour:UIColor, forSection section:Int)
}


protocol DDColourPickerDataSource: class {
    
    
    /// Returns the number of sections that the colour picker should present
    ///
    /// - Parameter colourPicker: the colour picker associated with this call
    func numberOfSections(in colourPicker:DDColourPicker) -> Int
    
    
    /// Returns the diameter for the circle colour objects that the user will select
    ///
    /// - Parameter colourPicker: the colour picker associated with this call
    func circleDiameter(for colourPicker:DDColourPicker) -> CGFloat
    
    
    /// Returns the title for the given section index
    ///
    /// - Parameters:
    ///   - colourPicker: the colour picker associated with this call
    ///   - section: the section index for which the title is requested
    func colourPicker(_ colourPicker:DDColourPicker, titleForSection section:Int) -> String
    
    
    /// Returns the currently selected colour for the given section index
    ///
    /// - Parameters:
    ///   - colourPicker: the colour picker associated with this call
    ///   - section: the section index for which the default selection is requested
    func colourPicker(_ colourPicker:DDColourPicker, defaultSelectedColourForSection section:Int) ->UIColor
    
    
    /// Returns the number of colour options for the given section number
    ///
    /// - Parameters:
    ///   - colourPicker: the colour picker associated with this call
    ///   - section: the section index for which the number of colours is requested
    func colourPicker(_ colourPicker:DDColourPicker, numberOfColoursInSection section:Int) -> Int
    
    
    /// Returns a colour for the given section number and item index based on the numberOfcoloursInSection:
    /// call
    ///
    /// - Parameters:
    ///   - colourPicker: the colour picker associated with this call
    ///   - indexPath: An index path representing the item index and section number for which a colour is requested
    func colourPicker(_ colourPicker:DDColourPicker, colourForIndexPath indexPath:IndexPath) -> UIColor
}


class DDColourPicker: UIView, DDColourPickerHeaderSectionDelegate {
    
    // static constants
    static let HeaderInset:CGFloat = 15                             // Inset from the edges of the scroll view to begin the header sections
    static let InterSectionHeaderSpacing:CGFloat = 10               // Spacing between the header sections
    
    
    // optional user set fields
    weak var delegate: DDColourPickerDelegate?                      // delegate for the colour picker to notify for events such as colour selection changes
    weak var dataSource: DDColourPickerDataSource?                  // datasource for the colour picker to fetch information required to set this view up
    
    
    // private fields
    private var numSections:Int = 0                                 // the number of sections for the colour picker
    private var numColoursForCurrentSection:Int = 0                 // number of colours to present for the current section
    private var circleDiameter:CGFloat = 5                          // diameter of circles that will be presented
    private var currentSection = 0                                  // the current section that the colour picker is displaying options for
    private var selectedCircles:[DDColourBubble] = []               // the currently selected colour/circle for each section
    private var selectableCircles:[DDColourBubble] = []             // the colours/circles which can be selected for the current section
    private var headerSections:[DDColourPickerHeaderSection] = []   // the header section views for each section in the top header
    private var headerView:UIScrollView!                            // the scroll view which contains the the header content view
    private var headerContentView:UIView!                           // the content view which contains the indvidual section headers that is then placed in the scroll view
    private var headerSelectionRing:UIView!                         // the ring that goes around the circle for the current section colour
    private var initialSetup:Bool = false                           // whether the view has been setup
    
    var BPAnimator: UIDynamicAnimator!
    var BPCollision: UICollisionBehavior!
    var BPGravity: UIFieldBehavior!
    var BPDynamics: UIDynamicItemBehavior!
    var gravPos: CGPoint!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    
    /// setup
    ///
    /// Sets up the view with the appropriate header view and the colours ready to be selected
    /// for the current section
    ///
    private func setup() {
        if !initialSetup {
            
            BPAnimator = UIDynamicAnimator(referenceView: self)
//            BPAnimator.setValue(true, forKey: "debugEnabled") // Private API. See the bridging header.
            
            BPGravity = UIFieldBehavior.radialGravityField(position: self.center)
            BPGravity.falloff = 0.3
            BPGravity.strength = 3
            BPGravity.animationSpeed = 7
            gravPos = self.center
            
            // clear the current layout
            for view in self.subviews {
                view.removeFromSuperview()
            }
            
            // get setup information from the data source
            numSections = dataSource?.numberOfSections(in: self) ?? 0
            circleDiameter = dataSource?.circleDiameter(for: self) ?? 0
            currentSection = 0

            // construct the subviews
            constructHeader()
            constructSection(sectionIndex: currentSection, animated: true)
            
            
            
            BPDynamics = UIDynamicItemBehavior(items: self.selectableCircles);
            BPDynamics.allowsRotation = false;
            BPDynamics.resistance = 0.8

            BPCollision = UICollisionBehavior(items: self.selectableCircles)
            BPCollision.setTranslatesReferenceBoundsIntoBoundary(with: UIEdgeInsets(top: 0, left: -500, bottom: 0, right: -500))
            BPCollision.collisionMode = .everything

            BPAnimator.addBehavior(BPDynamics)
            BPAnimator.addBehavior(BPGravity)
            BPAnimator.addBehavior(BPCollision)
            
            initialSetup = true
        }
    }
    

    /// constructHeader
    ///
    /// Constructs the header view and adds it to the view. If the header has more sections than
    /// can fit on the screen then it will be scrollable. Sets the current section header to the
    /// currently selected section. Also fetches the currently selected colours for all the sections.
    ///
    private func constructHeader() {
        // make the scroll view
        let headerHeight = max(self.frame.height * 0.15, circleDiameter + 20)
        headerView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: headerHeight))
        headerView.showsHorizontalScrollIndicator = false
        headerView.showsVerticalScrollIndicator = false
        self.addSubview(headerView)
        
        // create the content view and cycle through the number of section headers requesting the title
        headerContentView = UIView()
        var xPos = DDColourPicker.HeaderInset
        let sectionWidth = max(circleDiameter + 20, self.frame.width/4)
        
        for i in 0 ..< numSections {
            let sectionTitle = dataSource?.colourPicker(self, titleForSection: i) ?? ""
            let sectionSelectedColour = dataSource?.colourPicker(self, defaultSelectedColourForSection: i) ?? UIColor.blue
            
            let sectionView = DDColourPickerHeaderSection(frame: CGRect(x: xPos,
                                                                        y: 0,
                                                                        width: sectionWidth,
                                                                        height: headerHeight),
                                                          text: sectionTitle,
                                                          circleDiameter: circleDiameter,
                                                          colour: sectionSelectedColour)
            sectionView.delegate = self
            sectionView.tag = i
            
            headerSections += [sectionView]
            headerContentView.addSubview(sectionView)
            
            // create the circle for the currently selected view so that we can later add it to the view when/if it becomes deselected
            let circle = DDColourBubble(colour: sectionSelectedColour, diameter: circleDiameter)
            circle.center = self.center
            circle.alpha = 0
            circle.transform = CGAffineTransform(scaleX: 0, y: 0)
            circle.addTarget(self, action: #selector(self.didPressCircle(sender:)), for: .touchUpInside)
            selectedCircles += [circle]
            
            xPos += (i == numSections - 1) ? sectionWidth + DDColourPicker.HeaderInset : sectionWidth + DDColourPicker.InterSectionHeaderSpacing
        }
        
        // add the header to the scroll view either centre it if the width is less than the view width otherwise
        // just add it at the 0 index and let the scroll view handle the scrolling
        if xPos > self.frame.width {
            headerContentView.frame = CGRect(x: 0, y: 0, width: xPos, height: headerHeight)
        } else {
            headerContentView.frame = CGRect(x: (self.frame.width/2) - (xPos/2), y: 0, width: xPos, height: headerHeight)
        }
        headerView.addSubview(headerContentView)
        headerView.contentSize = CGSize(width: headerContentView.frame.width, height: headerHeight)
        headerView.isScrollEnabled = true
        
        // add the selection ring to the header
        if numSections > 0 {
            headerSelectionRing = UIView(frame: CGRect(origin: CGPoint.zero,
                                                       size: CGSize(width: self.circleDiameter,
                                                                    height: self.circleDiameter)))
            headerSelectionRing.layer.cornerRadius = circleDiameter/2
            headerSelectionRing.backgroundColor = UIColor.clear
            headerSelectionRing.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            headerSelectionRing.layer.borderWidth = 1.5
            headerSelectionRing.layer.borderColor = UIColor.black.cgColor
            headerSelectionRing.center = headerSections[currentSection].convert(headerSections[currentSection].getDotPoint(), to: headerContentView)
            headerContentView.addSubview(headerSelectionRing)
            headerSections[currentSection].isSelected = true
        }
    }
    
    
    /// constructSection
    ///
    /// Constructs the circle colours that are selectable for the current section and animates their
    /// presentation.
    ///
    /// - Parameters:
    ///   - sectionIndex: the section for which colours to present
    ///   - animated: whether the presentation should be animated
    ///
    private func constructSection(sectionIndex:Int, animated:Bool) {
        // get number of circles for the current section
        numColoursForCurrentSection = dataSource?.colourPicker(self, numberOfColoursInSection: sectionIndex) ?? 0
        
        // construct the circles for the current section
        var newCircles:[DDColourBubble] = []
        for i in 0 ..< numColoursForCurrentSection {
            let bubbleColour = dataSource?.colourPicker(self, colourForIndexPath: IndexPath(item: i, section: sectionIndex)) ?? UIColor.blue
            let circle = DDColourBubble(colour: bubbleColour, diameter: circleDiameter)
            circle.center = CGPoint(x: self.frame.width * CGFloat.random(in: 0...1), y: self.frame.height * CGFloat.random(in: 0...1))
            circle.tag = i
            circle.alpha = animated ? 0 : 1
            circle.transform = animated ? CGAffineTransform(scaleX: 0, y: 0) : CGAffineTransform.identity
            circle.addTarget(self, action: #selector(self.didPressCircle(sender:)), for: .touchUpInside)

            // TOOO: need to add phsysics properties to the view and setup the location of the view properly
            BPGravity.addItem(circle)
            
            newCircles += [circle]
        }
        
        
        if animated {
            // add new views as subviews
            for circle in newCircles {
                self.addSubview(circle)
            }
            
            // animate them popping in and old views popping out
            let animateInAnimation = {
                UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: [.beginFromCurrentState, .curveEaseInOut], animations: {() in
                    for circle in newCircles {
                        circle.alpha = 1
                        circle.transform = CGAffineTransform.identity
                    }
                }, completion: {(success:Bool) in
                    for circle in self.selectableCircles {
                        circle.removeFromSuperview()
                    }
                    self.selectableCircles = newCircles
                })
            }
            
            if self.selectableCircles.count > 0 {
                UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: [.beginFromCurrentState, .curveEaseInOut], animations: {() in
                    for circle in self.selectableCircles {
                        circle.transform = CGAffineTransform(scaleX: 0, y: 0)
                    }
                }, completion: {(success:Bool) in
                    animateInAnimation()
                })
            } else {
                animateInAnimation()
            }
        } else {
            
            // remove old views
            for circle in self.selectableCircles {
                circle.removeFromSuperview()
            }
            
            // add new views
            for circle in newCircles {
                self.addSubview(circle)
            }
            
            self.selectableCircles = newCircles
        }
    }
    
    
    /// didPressCircle
    ///
    /// Callback when a circle is pressed which swaps the currently selected colour with the colour of the tapped circle
    ///
    /// - Parameter sender: the view which triggered the action
    ///
    @objc func didPressCircle(sender:DDColourBubble) {
        let snapPt = headerSections[currentSection].convert(headerSections[currentSection].getDotPoint(), to: self)
        headerSections[currentSection].fadeDotOut()
        
        // swap circles in selectable to selected
        selectColour(selected: sender)
        
        // animate one view up
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: [.beginFromCurrentState, .curveEaseInOut], animations: {() in
            sender.center = snapPt
            for view in self.selectableCircles {
                view.alpha = 1
                view.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }, completion: {(success:Bool) in
            self.headerSections[self.currentSection].replaceColour(colour: sender.backgroundColor ?? UIColor.blue)
            for view in self.selectedCircles {
                view.alpha = 0
                view.transform = CGAffineTransform(scaleX: 0, y: 0)
                view.removeFromSuperview()
            }
        })
    }
    
    
    /// selectColour
    ///
    /// Selects the colour/circle that is provided and swaps it with the currently selected colour for the current section
    /// and also notifies the delegate of the change
    ///
    /// - Parameter selected: the selected colour view
    ///
    private func selectColour(selected:DDColourBubble) {
        // swap circles in selectable to selected
        let previouslySelectedColour = selectedCircles[currentSection]
        previouslySelectedColour.tag = selected.tag
        selectedCircles[currentSection] = selected
        selectableCircles.remove(at: selected.tag)
        selectableCircles.insert(previouslySelectedColour, at: previouslySelectedColour.tag)
        previouslySelectedColour.center = CGPoint(x: self.frame.width * CGFloat.random(in: 0...1), y: self.frame.height * CGFloat.random(in: 0...1))
        self.addSubview(previouslySelectedColour)
        
        BPGravity.removeItem(selected)
        BPGravity.addItem(previouslySelectedColour)

        delegate?.colourPicker(self, didSelectColour: selected.backgroundColor!, forSection: currentSection)
    }
    
    
    // MARK: - DDColourPickerHeaderSectionDelegate
    
    
    
    /// didPressHeaderSection
    ///
    /// callback for when a section header is selected and so that the current section is switched to
    /// also triggers reloading the colours for the next section
    ///
    /// - Parameter section: the section that was tapped triggering this action
    ///
    func didPressHeaderSection(section: DDColourPickerHeaderSection) {
        headerSections[currentSection].isSelected = false
        headerView.scrollRectToVisible(section.frame, animated: true)
        currentSection = section.tag
        headerSections[currentSection].isSelected = true
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: [.beginFromCurrentState], animations: {() in
            self.headerSelectionRing.center = section.convert(section.getDotPoint(), to: self.headerContentView)
        }, completion: nil)
        constructSection(sectionIndex: currentSection, animated: true)
    }
    
}
