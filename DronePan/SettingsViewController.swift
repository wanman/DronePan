/*
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import UIKit

@objc class SettingsViewController: UIViewController {
    
    var model:String = ""
    var handheld: Bool = false
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var startDelayControl: UISegmentedControl!
    @IBOutlet weak var photosPerRowControl: UISegmentedControl!
    @IBOutlet weak var skyRowControl: UISegmentedControl!

    @IBOutlet weak var angleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var startDelayDescription: UILabel!
    @IBOutlet weak var skyRowDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSettings()
    }
    
    private func initSegment(control: UISegmentedControl, setting : Int) {
        for i in 0..<control.numberOfSegments {
            
            if let title = control.titleForSegmentAtIndex(i) {
                if let segment = Int(title) {
                    if (segment == setting) {
                        control.selectedSegmentIndex = Int(i)
                    }
                }
            }
        }
    }
    
    func initSettings() {
        titleLabel.attributedText = NSAttributedString(string: "\(model) Settings", attributes: [
            NSFontAttributeName : UIFont.boldSystemFontOfSize(20),
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
        ])
        
        if (handheld) {
            startDelayControl.enabled = true
            startDelayDescription.text = "Specify a delay before starting your pano. The pano process will delay this amount of time after clicking the start button."
            
            let startDelay = ModelSettings.startDelay(model)
            initSegment(startDelayControl, setting: startDelay)
            
            skyRowDescription.text = "Only applicable for aircraft"
            skyRowControl.enabled = false
            skyRowControl.selectedSegmentIndex = 0
        } else {
            startDelayControl.selectedSegmentIndex = UISegmentedControlNoSegment
            startDelayControl.enabled = false
            startDelayDescription.text = "Only applicable for handheld"
            
            skyRowControl.enabled = true
            skyRowDescription.text = "If set, DronePan will shoot a \"sky row\" with the gimbal at +30˚. Then it will take a row of shots at 0˚, -30˚ and -60˚ and one nadir. Selecting \"No\" will skip the sky row."

            let skyRow = ModelSettings.skyRow(model)
            
            if (skyRow) {
                skyRowControl.selectedSegmentIndex = 0
            } else {
                skyRowControl.selectedSegmentIndex = 1
            }
        }
        
        let photosPerRow = ModelSettings.photosPerRow(model)
        initSegment(photosPerRowControl, setting: photosPerRow)
        
        updateCounts()
    }
    
    private func setAngleLabel(angle: Float) {
        let angleString = NSMutableAttributedString(string: "\(angle)", attributes: [
            NSFontAttributeName : UIFont.boldSystemFontOfSize(14)
        ])
        
        
        angleString.appendAttributedString(NSAttributedString(string: "˚", attributes: [
            NSFontAttributeName : UIFont.systemFontOfSize(14)
            ]))
        
        angleLabel.attributedText = angleString
    }
    
    private func updateCounts() {
        var numberOfRows = ModelSettings.numberOfRows(model)
        
        if (isSkyRow()) {
            numberOfRows += 1
        }
        
        if let photosPerRow = selectedPhotosPerRow() {
            self.setAngleLabel(360.0/Float(photosPerRow))
            self.countLabel.text = "\((numberOfRows * photosPerRow) + 1)"
        } else {
            self.setAngleLabel(0)
            self.countLabel.text = "--"
        }
    }
    
    private func isSkyRow() -> Bool {
        return skyRowControl.selectedSegmentIndex == 0
    }

    private func selectedValue(control: UISegmentedControl) -> Int? {
        if (control.selectedSegmentIndex == UISegmentedControlNoSegment) {
            return nil
        }
        
        if let title = control.titleForSegmentAtIndex(control.selectedSegmentIndex) {
            return Int(title)
        } else {
            return nil
        }
    }

    private func selectedPhotosPerRow() -> Int? {
        return selectedValue(photosPerRowControl)
    }

    private func selectedStartDelay() -> Int? {
        return selectedValue(startDelayControl)
    }
    
    @IBAction func photosPerRowChanged(sender: AnyObject) {
        updateCounts()
    }
    
    @IBAction func skyRowChanged(sender: AnyObject) {
        updateCounts()
    }

    @IBAction func saveSettings(sender: AnyObject) {
        var settings : [SettingsKeys : AnyObject] = [
            .SkyRow : isSkyRow()
        ]
        
        if let startDelay = selectedStartDelay() {
            settings[.StartDelay] = startDelay
        }
        
        if let photoCount = selectedPhotosPerRow() {
            settings[.PhotosPerRow] = photoCount
        }
        
        ModelSettings.updateSettings(model, settings: settings)
        
        // Dismiss the VC
        self.dismissViewControllerAnimated(true, completion: {})
    }
}