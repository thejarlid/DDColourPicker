//
//  ViewController.swift
//  DDColourPicker
//
//  Created by Dilraj Devgun on 3/20/20.
//  Copyright © 2020 Dilraj Devgun. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DDColourPickerDataSource, DDColourPickerDelegate {

    var colourpicker:DDColourPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.colourpicker = DDColourPicker(frame: CGRect(origin: CGPoint(x: 0, y: self.view.frame.height * 0.1), size: CGSize(width: self.view.frame.width, height: self.view.frame.height * 0.9)))
        self.colourpicker.delegate = self
        self.colourpicker.dataSource = self
        self.view.addSubview(self.colourpicker)
    }
    
    func colourPicker(_ colourPicker: DDColourPicker, titleForSection section: Int) -> String {
        return "section \(section)"
    }
    
    func colourPicker(_ colourPicker: DDColourPicker, numberOfColoursInSection section: Int) -> Int {
        return 5
    }
    
    func colourPicker(_ colourPicker: DDColourPicker, colourForIndexPath indexPath: IndexPath) -> UIColor {
        return UIColor.randomColor()
    }
    
    func colourPicker(_ colourPicker: DDColourPicker, defaultSelectedColourForSection section: Int) -> UIColor {
        return UIColor.randomColor()
    }
    
    func numberOfSections(in colourPicker: DDColourPicker) -> Int {
        return 3
    }
    
    func circleDiameter(for colourPicker: DDColourPicker) -> CGFloat {
        return 50
    }
    
    func colourPicker(_ colourPicker: DDColourPicker, didSelectColour colour: UIColor, forSection section: Int) {
        print("picked new colour for section \(section)")
    }
}

extension UIColor {
    class func randomColor(randomAlpha: Bool = false) -> UIColor {
        let redValue = CGFloat(arc4random_uniform(255)) / 255.0;
        let greenValue = CGFloat(arc4random_uniform(255)) / 255.0;
        let blueValue = CGFloat(arc4random_uniform(255)) / 255.0;
        let alphaValue = randomAlpha ? CGFloat(arc4random_uniform(255)) / 255.0 : 1;

        return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: alphaValue)
    }
}
