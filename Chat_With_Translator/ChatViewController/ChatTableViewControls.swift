//
//  ChatControls.swift
//  Chat_With_Translator
//
//  Created by Admin on 23/01/2019.
//  Copyright © 2019 xelwow98. All rights reserved.
//

import Foundation
import UIKit

class BubbleView : UIView {
    @IBOutlet weak var originTextLabel : UILabel!
    @IBOutlet weak var translatedTextLabel : UILabel!
}

class ChatCell : UITableViewCell {
    @IBOutlet weak var bubbleView : BubbleView!
    @IBOutlet weak var view : UIView!
    
    func setUp(origin : String, translation : String, sended : Bool){
            self.bubbleView.originTextLabel.text = origin
            self.bubbleView.originTextLabel.sizeToFit()
            self.bubbleView.translatedTextLabel.text = translation
            self.bubbleView.translatedTextLabel.sizeToFit()
            
            self.bubbleView.layer.cornerRadius = 2
            
            let botCorner = sended ? UIRectCorner.bottomRight : .bottomLeft
            
            let maskPath = UIBezierPath(roundedRect: self.bubbleView.bounds,
                                        byRoundingCorners: [.topLeft, .topRight, botCorner],
                                        cornerRadii: CGSize(width: 16.0, height: 0.0))
            let maskLayer = CAShapeLayer()
            maskLayer.path = maskPath.cgPath
            self.bubbleView.layer.mask = maskLayer
            self.bubbleView.sizeToFit()
        
        
        
    }
}
