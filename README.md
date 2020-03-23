# DDColourPicker

DDColourPicker is a lightweight view that provides an interactive way for user's to select a colour and associate it to a given cateogry. It provides colours in circles which float around within the view and then snap to their associated position. The view is design to be incredibly simple to use and add. 

## Screenshots



## Usage 

The control is designed to be familiar to UITableView where a datasource and delegete help provide setup information and interaction communication between the control and the user. To use the control create the view and set its delegate and data source. The control will then setup the rest. A sample usage is provided in the view controller for this project.

To add this to your project copy DDColourPicker.swift and DDColourPickerHeaderSection.swift into your source directoty

### Data Source Conformance 

The data source is the most important part of the view as it provides the means for which the colour is populated in the view.
The following methods must be implemented:
```
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
```

## Collaboration

Feel free to extend this control, use it for your project, and suggest any improvements you'd like to see. 

## License

MIT License

Copyright (c) 2020 Dilraj Devgun

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
