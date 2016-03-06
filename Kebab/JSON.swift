//
//  JSON.swift
//  Kebab
//
//  Created by Sasha Prokhorenko on 9/27/15.
//  Copyright © 2015 Minikin. All rights reserved.
//

import Foundation

public protocol JSONValue {
  subscript(key key: String) -> JSONValue? { get }
  subscript(index index: Int) -> JSONValue? { get }
}

extension String : JSONValue {
  public subscript(key key: String) -> JSONValue? { return nil }
  public subscript(index index: Int) -> JSONValue? { return nil }
}

extension Double : JSONValue {
  public subscript (key key : String) -> JSONValue? { return nil }
  public subscript (index index: Int) -> JSONValue? {return nil}
}

extension Int : JSONValue {
  public subscript (key key : String) -> JSONValue? { return nil }
  public subscript (index index: Int) -> JSONValue? {return nil}
}

extension Bool : JSONValue {
  public subscript (key key : String) -> JSONValue? { return nil }
  public subscript (index index: Int) -> JSONValue? {return nil}
}

extension NSNull : JSONValue {
  public subscript(key key: String) -> JSONValue? { return nil }
  public subscript(index index: Int) -> JSONValue? { return nil }
}

extension NSNumber : JSONValue {
  public subscript(key key: String) -> JSONValue? { return nil }
  public subscript(index index: Int) -> JSONValue? { return nil }
}

extension NSArray : JSONValue {
  public subscript(key key: String) -> JSONValue? { return nil }
  public subscript(index index: Int) -> JSONValue? { return index < count && index >= 0 ? JSON(self[index]) : nil }
}

extension NSDictionary : JSONValue {
  public subscript(key key: String) -> JSONValue? { return JSON(self[key]) }
  public subscript(index index: Int) -> JSONValue? { return nil }
}


public func JSON(object: AnyObject?) -> JSONValue? {
  if let some: AnyObject = object {
    switch some {
      case let string as String:    return string
      case let double as Double:    return double
      case let integer as Int:      return integer
      case let bool as Bool:        return bool
      case let null as NSNull:      return null
      case let number as NSNumber:  return number
      case let array as NSArray:      return array
      case let dict as NSDictionary:  return dict
    default:                        return nil
    }
  } else {
    return nil
  }
}
