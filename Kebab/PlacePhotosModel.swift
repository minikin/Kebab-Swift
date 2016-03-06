//
//  PlacePhotosModel.swift
//  Kebab
//
//  Created by Sasha Prokhorenko on 10/1/15.
//  Copyright © 2015 Minikin. All rights reserved.
//

import RealmSwift

class PlacePhotosModel: Object {
  
  dynamic var photoId = ""
  dynamic var photoString = ""
  dynamic var updatedAt = NSDate()
  
  override static func primaryKey() -> String? {
    return "photoId"
  }
}