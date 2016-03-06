//
//  PlaceFlowLayout.swift
//  Kebab
//
//  Created by Sasha Prokhorenko on 9/24/15.
//  Copyright © 2015 Minikin. All rights reserved.
//

import UIKit

class PlaceFlowLayout: UICollectionViewFlowLayout {
  
  // MARK: - Center KebabCell on screen
  
  override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
    
    var offsetAdjustment = MAXFLOAT;
    let horizontalOffset = proposedContentOffset.x + (self.collectionView!.bounds.size.width - self.itemSize.width) / 2.0
    let targetRect = CGRectMake(proposedContentOffset.x, 0, self.collectionView!.bounds.size.width, self.collectionView!.bounds.size.height)
    
    let array = super.layoutAttributesForElementsInRect(targetRect)
    
    for layoutAttributes in array! {
      let itemOffset = layoutAttributes.frame.origin.x;
      if (fabsf(Float(itemOffset - horizontalOffset)) < fabsf(offsetAdjustment)) {
        offsetAdjustment = Float(itemOffset - horizontalOffset)
      }
    }
    
    let offsetX = Float(proposedContentOffset.x) + offsetAdjustment
    return CGPointMake(CGFloat(offsetX), proposedContentOffset.y)
  }

}
