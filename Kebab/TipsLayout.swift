//
//  TipsLayout.swift
//  Kebab
//
//  Created by Sasha Minikin on 12/15/15.
//  Copyright © 2015 Minikin. All rights reserved.
//

import UIKit


protocol TipsLayoutDelegate {
  
  // Method to ask the delegate for the height of the image
  
  func collectionView(collectionView: UICollectionView, heightForCommentAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
  
  // Method to ask the delegate for the height of the annotation text
  
  func collectionView(collectionView: UICollectionView, heightForAnnotationtAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
}


class TipsLayoutAttributes : UICollectionViewLayoutAttributes {
  
  // Custom attribute
  
  var commentHeight : CGFloat = 0
 
  // Override copyWithZone to conform to NSCopying protocol
  
  override func copyWithZone(zone: NSZone) -> AnyObject {
    let copy = super.copyWithZone(zone) as! TipsLayoutAttributes
    copy.commentHeight = commentHeight
    return copy
  }
  
  
  // Override isEqual
  
  override func isEqual(object: AnyObject?) -> Bool {
    if let attributes = object as? TipsLayoutAttributes {
      if attributes.commentHeight == commentHeight {
        return super.isEqual(object)
      }
    }
    return false
  }

}

class TipsLayout : UICollectionViewLayout {
  
  
  // Layout Delegate
  
  var delegate: TipsLayoutDelegate!
  
  // Configurable properties
  
  var numberOfColumns = 1
  var cellPadding: CGFloat = 0
  let headerHeight : CGFloat = 60
  
  // layoutAttributes
  
  private var layoutAttributes = Dictionary<String, UICollectionViewLayoutAttributes>()
  
  // TODO: - NEW LINE
  
  private var cache = [TipsLayoutAttributes]()
  
  // Content height and size
  
  private var contentHeight: CGFloat = 0
  private var width : CGFloat {
    get {
      let insets = collectionView!.contentInset
      return CGRectGetWidth(collectionView!.bounds) - (insets.left + insets.right)
    }
  }
  
  
  // MARK: -  Required methods
  
  override  class func layoutAttributesClass() -> AnyClass {
    return TipsLayoutAttributes.self
  }
  
  override func collectionViewContentSize() -> CGSize {
    return CGSize(width: width, height: contentHeight)
  }
  
  
  // MARK: -  prepareLayout
  
  override func prepareLayout() {
  
    // Only calculate once
    
    if layoutAttributes.isEmpty {
      
      let path = NSIndexPath(forItem: 0, inSection: 0)
      let headerAttributes = TipsLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withIndexPath: path)
      headerAttributes.frame = CGRectMake(0, 0, self.collectionView!.frame.size.width, headerHeight)
      
      let headerKey = layoutKeyForHeaderAtIndexPath(path)
    
      layoutAttributes[headerKey] = headerAttributes
      
      
      // Pre-Calculates the X Offset for every column and adds an array to increment the currently max Y Offset for each column
      
      let columnWidth = width / CGFloat(numberOfColumns)
      
      var xOffsets = [CGFloat]()
      for column in 0..<numberOfColumns {
        xOffsets.append(CGFloat(column) * columnWidth)
      }
      
      // 
      var yOffsets = [headerHeight, headerHeight] + [CGFloat](count: numberOfColumns, repeatedValue: 0)
      var column = 0
      
      // Iterates through the list of items in the first section
      
      for item in 0..<collectionView!.numberOfItemsInSection(0) {
        
        let indexPath = NSIndexPath(forItem: item, inSection: 0)
        
        // Asks the delegate for the height of the picture and the annotation and calculates the cell frame.
        
        let width = columnWidth - (cellPadding * 2)
        let commentHeight = delegate.collectionView(collectionView!, heightForCommentAtIndexPath: indexPath, withWidth: width)
        let annotationHeight = delegate.collectionView(collectionView!, heightForAnnotationtAtIndexPath: indexPath, withWidth: width)
        let height = cellPadding + commentHeight + annotationHeight + cellPadding
        let frame = CGRect(x: xOffsets[column], y: yOffsets[column], width: columnWidth, height: height)
        let insetFrame = CGRectInset(frame, cellPadding, cellPadding)
        
        // Creates an UICollectionViewLayoutItem with the frame and add it to the cache
        
        let attributes = TipsLayoutAttributes(forCellWithIndexPath: indexPath)
        attributes.frame = insetFrame
        attributes.commentHeight = commentHeight
        let key = layoutKeyForIndexPath(indexPath)
        layoutAttributes[key] = attributes
        
        // Updates the collection view content height
        
        contentHeight = max(contentHeight, CGRectGetMaxY(frame))
        yOffsets[column] = yOffsets[column] + height
        
        column = column >= (numberOfColumns - 1) ? 0 : ++column
      }
    
      
    } else {
      layoutAttributes.removeAll()
    }
    
  }

  override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    
    let predicate = NSPredicate {[unowned self] (evaluatedObject, bindings) -> Bool in
      let layoutAttribute = self.layoutAttributes[evaluatedObject as! String]
      return CGRectIntersectsRect(rect, layoutAttribute!.frame)
    }
    
    let dict = layoutAttributes as NSDictionary
    let keys = dict.allKeys as NSArray
    let matchingKeys = keys.filteredArrayUsingPredicate(predicate)
    let dictObjects = dict.objectsForKeys(matchingKeys, notFoundMarker: NSNull()) as! [UICollectionViewLayoutAttributes]
    
    return dictObjects
  }
  
  override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    let headerKey = layoutKeyForHeaderAtIndexPath(indexPath)
    return layoutAttributes[headerKey]
  }
  
  override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    let key = layoutKeyForIndexPath(indexPath)
    return layoutAttributes[key]
  }
  
  // MARK: Invalidate
  
  override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    return !CGSizeEqualToSize(newBounds.size, self.collectionView!.frame.size)
  }
  
  
  // MARK: - Helpers
  
  func layoutKeyForIndexPath(indexPath : NSIndexPath) -> String {
    return "\(indexPath.section)_\(indexPath.row)"
  }
  
  func layoutKeyForHeaderAtIndexPath(indexPath : NSIndexPath) -> String {
    return "s_\(indexPath.section)_\(indexPath.row)"
  }
  

}