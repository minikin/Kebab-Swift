//
//  PaddingLabel.swift
//  Kebab
//
//  Created by Sasha Minikin on 2/16/16.
//  Copyright © 2016 Minikin. All rights reserved.
//

import UIKit


class PaddingLabel: UILabel {
  
  let padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
  
  override func drawTextInRect(rect: CGRect) {
    super.drawTextInRect(UIEdgeInsetsInsetRect(rect, padding))
  }
  
  // Override -intrinsicContentSize: for Auto layout code
  override func intrinsicContentSize() -> CGSize {
    let superContentSize = super.intrinsicContentSize()
    let width = superContentSize.width + padding.left + padding.right
    let heigth = superContentSize.height + padding.top + padding.bottom
    return CGSize(width: width, height: heigth)
  }
  
  // Override -sizeThatFits: for Springs & Struts code
  override func sizeThatFits(size: CGSize) -> CGSize {
    let superSizeThatFits = super.sizeThatFits(size)
    let width = superSizeThatFits.width + padding.left + padding.right
    let heigth = superSizeThatFits.height + padding.top + padding.bottom
    return CGSize(width: width, height: heigth)
  }
  
}


