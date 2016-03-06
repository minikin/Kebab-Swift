//
//  TipsHeaderView.swift
//  Kebab
//
//  Created by Sasha Minikin on 12/15/15.
//  Copyright © 2015 Minikin. All rights reserved.
//

import UIKit

class TipsHeaderView: UICollectionReusableView {
  
  
  // Hide tipsCollectionView
  
  @IBAction func hideTipsTVCell(sender: AnyObject) {
    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.hideTipsCollectionViewNotification, object: nil)
  }
  
}
