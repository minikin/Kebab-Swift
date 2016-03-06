//
//  TipsCollectionViewCell.swift
//  Kebab
//
//  Created by Sasha Minikin on 12/14/15.
//  Copyright © 2015 Minikin. All rights reserved.
//

import UIKit

class TipsCollectionViewCell: UICollectionViewCell {
  

  @IBOutlet weak var commentViewHeightLayoutConstraint: NSLayoutConstraint!
  @IBOutlet weak var tipsLabel: PaddingLabel!
  @IBOutlet weak var userName: UILabel!
  
  
  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
    super.applyLayoutAttributes(layoutAttributes)
    let attributes =  layoutAttributes as! TipsLayoutAttributes
    commentViewHeightLayoutConstraint.constant = attributes.commentHeight
  }
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    tipsLabel.sizeToFit()
  }
  

}