//
//  ChangeLanguageButton.swift
//  Chat_With_Translator
//
//  Created by Admin on 24/01/2019.
//  Copyright © 2019 xelwow98. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class ChangeLanguageSwitch : UISwitch {
    @IBOutlet weak var firstLanguageImage : UIImageView!
    @IBOutlet weak var secondLanguageImage : UIImageView!
    @IBOutlet weak var view : UIView!
    
    @IBOutlet weak var switchGestureRecognizer : UITapGestureRecognizer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 38.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func switchValueChanged (_ sender : Any){
        if self.isOn {
            // Change position of images
            changePositionOfImages(frontImage: firstLanguageImage, backImage: secondLanguageImage)
        }
        else{
            // Change position of images
            changePositionOfImages(frontImage: secondLanguageImage, backImage: firstLanguageImage)
        }
    }
    
    func changePositionOfImages(frontImage : UIImageView, backImage : UIImageView){
        UIView.animate(withDuration: 1.0) {
            let positionOfFirstImage = frontImage.frame.origin
            frontImage.frame.origin = backImage.frame.origin
            backImage.frame.origin = positionOfFirstImage
            self.inputView?.bringSubviewToFront(backImage)
        }
    }
}
