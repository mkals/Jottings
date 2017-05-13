//
//  TableViewCell.swift
//  Jottings
//
//  Created by Morten Kals on 13/05/2017.
//  Copyright © 2017 Kals. All rights reserved.
//

import UIKit

class VersionsTableViewCell: UITableViewCell {

    @IBOutlet weak var detailField: UILabel!
    @IBOutlet weak var titleField: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
