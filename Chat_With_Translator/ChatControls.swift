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
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func setupCell(){
        bubbleView.layer.cornerRadius = 3
    }
    
}

class ChatTableView : UITableView {
    
    var messages : [ChatCell]!
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
