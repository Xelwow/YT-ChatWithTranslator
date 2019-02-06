//
//  ChangeLanguageButton.swift
//  Chat_With_Translator
//
//  Created by Admin on 24/01/2019.
//  Copyright © 2019 xelwow98. All rights reserved.
//

import Foundation
import UIKit



protocol ChangeLanguageSwitchDelegate: class {
    func LanguageChangeButtonTapped()
}

@IBDesignable
class ChangeLanguageSwitch : UIView{
    @IBOutlet weak var firstLanguageImage : UIImageView!
    var firstLanguageName = "Русский"
    @IBOutlet weak var secondLanguageImage : UIImageView!
    var secondLanguageName = "Английский"
    
    @IBOutlet var view: UIView!
    var delegate : ChangeLanguageSwitchDelegate?
    var changed = false
    
    
    var protDel : ChangeLanguageSwitchDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSwitcher()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSwitcher()
    }
    
    private func setupSwitcher(){
        Bundle.main.loadNibNamed("ChangeLanguageSwitch", owner: self, options: nil)
        /*self.layer.cornerRadius = 18
        view.layer.cornerRadius = 18*/
        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    @IBAction func controlTap( recognizer : UITapGestureRecognizer){
        print("ChangeLanguageSwitch")
        if changed {
            changePositionOfImages(frontImage: secondLanguageImage, backImage: firstLanguageImage)
            changed = false
        }
        else{
            changePositionOfImages(frontImage: firstLanguageImage, backImage: secondLanguageImage)
            changed = true
        }
    }
    
    
    func changePositionOfImages(frontImage : UIImageView, backImage : UIImageView){
        UIView.animate(withDuration: 0.25) {
            self.delegate?.LanguageChangeButtonTapped()
            self.view.bringSubviewToFront(backImage)
            let positionOfFirstImage = frontImage.frame.origin
            frontImage.frame.origin = backImage.frame.origin
            backImage.frame.origin = positionOfFirstImage
            
        }
    }
    
}
