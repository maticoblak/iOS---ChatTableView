//
//  ChatMessageTableViewCell.swift
//  ChatTableView
//
//  Created by Matic Oblak on 2/23/17.
//  Copyright © 2017 Kamino. All rights reserved.
//

import UIKit

class ChatMessageTableViewCell: UITableViewCell {

    @IBOutlet private weak var messageLabel: UILabel?
    @IBOutlet private weak var containerView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView?.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
    }
    
    var message: String? {
        didSet {
            messageLabel?.text = message
        }
    }
}
