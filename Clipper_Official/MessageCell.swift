//
//  MessageCell.swift
//  Clipper_Official
//
//  Created by Bart Shaughnessy on 12/5/25.
//

import UIKit

class MessageCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
