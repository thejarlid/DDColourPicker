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
import SpriteKit

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



class DDColourPicker: UIView, DDColourPickerHeaderSectionDelegate, DDBubbleSceneDelegate {
    
    // static constants
    static let HeaderInset:CGFloat = 15                                 // Inset from the edges of the scroll view to begin the header sections
    static let InterSectionHeaderSpacing:CGFloat = 10                   // Spacing between the header sections
    
    
    // optional user set fields
    weak var delegate: DDColourPickerDelegate?                          // delegate for the colour picker to notify for events such as colour selection changes
    weak var dataSource: DDColourPickerDataSource?                      // datasource for the colour picker to fetch information required to set this view up
    
    
    // private fields
    private var numSections:Int = 0                                     // the number of sections for the colour picker
    private var numColoursForCurrentSection:Int = 0                     // number of colours to present for the current section
    private var circleDiameter:CGFloat = 5                              // diameter of circles that will be presented
    private var currentSection = 0                                      // the current section that the colour picker is displaying options for
    private var headerSections:[DDColourPickerHeaderSection] = []       // the header section views for each section in the top header
    private var headerView:UIScrollView!                                // the scroll view which contains the the header content view
    private var headerContentView:UIView!                               // the content view which contains the indvidual section headers that is then placed in the scroll view
    private var headerSelectionRing:UIView!                             // the ring that goes around the circle for the current section colour
    private var initialSetup:Bool = false                               // whether the view has been setup
    private let bubbleGen = UIImpactFeedbackGenerator(style: .medium)   // the generator which creates the haptic response on a bubble selection
    private let headerGen = UISelectionFeedbackGenerator()              // the generator which creates the haptic response on a header selection
    
    private var bubbleView: DDBubbleView! {                             // the bubble view which contains the spritekit scene
        didSet {
            bubbleScene.bubbleSceneDelegate = self
        }
    }
    
    private var bubbleScene: DDBubbleScene {                            // the SpriteKit scene which contains all the bubbles for the current section
        return bubbleView.bubbleScene
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    
    /// Sets up the view with the appropriate header view and the colours ready to be selected
    /// for the current section
    private func setup() {
        if !initialSetup {
            
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
            self.bubbleView = DDBubbleView(frame: CGRect(x: 0, y: self.headerView.frame.maxY, width: self.frame.width, height: self.frame.height - self.headerView.frame.maxY))
            self.addSubview(bubbleView)
            constructSection(sectionIndex: currentSection)
            
            initialSetup = true
        }
    }


    /// Constructs the header view and adds it to the view. If the header has more sections than
    /// can fit on the screen then it will be scrollable. Sets the current section header to the
    /// currently selected section. Also fetches the currently selected colours for all the sections.
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
    
    
    /// Constructs the current section and adds the bubbles to the view based on the colours we are presenting for the current section
    /// and animates them in given the provided direction
    ///
    /// - Parameters:
    ///   - sectionIndex: the section which is being set up
    ///   - animationDirection: the direction towards which to animate the new bubbles in
    private func constructSection(sectionIndex:Int, animationDirection:DDBubbleAnimationDirection = .All) {
        numColoursForCurrentSection = dataSource?.colourPicker(self, numberOfColoursInSection: sectionIndex) ?? 0
        
        // construct the circles for the current section
        var bubbles:[DDBubbleNode] = []
        for i in 0 ..< numColoursForCurrentSection {
            let bubbleColour = dataSource?.colourPicker(self, colourForIndexPath: IndexPath(item: i, section: sectionIndex)) ?? UIColor.blue
            let bubble = DDBubbleNode(colour: bubbleColour, radius: self.circleDiameter/2)
            if bubbleColour == dataSource?.colourPicker(self, defaultSelectedColourForSection: self.currentSection) ?? UIColor.blue {
                bubble.isSelected = true
            }
            bubbles.append(bubble)
        }
        bubbleScene.animateBubblesIn(bubbles: bubbles, direction: animationDirection, shouldFade: !initialSetup)
    }
    
    
    // MARK: - DDColourPickerHeaderSectionDelegate
    

    /// Callback for when a section header is selected and so that the current section is switched to
    /// also triggers reloading the colours for the next section
    ///
    /// - Parameter section: the section that was tapped triggering this action
    func didPressHeaderSection(section: DDColourPickerHeaderSection) {
        guard currentSection != section.tag else { return }
        headerSections[currentSection].isSelected = false
        headerView.scrollRectToVisible(section.frame, animated: true)
        let direction = currentSection < section.tag ? DDBubbleAnimationDirection.Left : DDBubbleAnimationDirection.Right
        currentSection = section.tag
        headerSections[currentSection].isSelected = true
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: [.beginFromCurrentState], animations: {() in
            self.headerSelectionRing.center = section.convert(section.getDotPoint(), to: self.headerContentView)
        }, completion: nil)
        constructSection(sectionIndex: currentSection, animationDirection: direction)
        headerGen.selectionChanged()
    }
    
    
    /// Callback when a bubble is selected, we change the header selected bubble with the selected
    /// bubble colour
    ///
    /// - Parameters:
    ///   - scene: the scene in which a bubble is selected
    ///   - bubble: the bubble which was selected
    func bubbleScene(_ scene: DDBubbleScene, didSelect bubble: DDBubbleNode) {
        print("didSelect -> \(bubble)")
        delegate?.colourPicker(self, didSelectColour: bubble.fillColor, forSection: currentSection)
        self.headerSections[self.currentSection].replaceColour(colour: bubble.fillColor)
        bubbleGen.impactOccurred()
    }
}
