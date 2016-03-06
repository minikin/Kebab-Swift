//
//  PlaceTipsModel.swift
//  Kebab
//
//  Created by Sasha Prokhorenko on 10/1/15.
//  Copyright © 2015 Minikin. All rights reserved.
//

import RealmSwift

class PlaceTipsModel: Object {
  
  dynamic var tipsId = ""
  dynamic var userId = ""
  dynamic var userFirstName = ""
  dynamic var userLastName = ""
  dynamic var text  = ""
  dynamic var tipsUpdatedAt = NSDate()
  
  
  override static func primaryKey() -> String? {
    return "tipsId"
  }
  
  ///Helper method that calculates the height of the tips based on the given font and the cell’s width
  
  func heightForTips(font: UIFont, width: CGFloat) -> CGFloat {
    let rect = NSString(string: text).boundingRectWithSize(CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
    return ceil(rect.height)
  }

  
}