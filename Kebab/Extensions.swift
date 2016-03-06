//
//  Extensions.swift
//  Kebab
//
//  Created by Sasha Prokhorenko on 10/23/15.
//  Copyright © 2015 Minikin. All rights reserved.
//

import Foundation
import UIKit
import PSOperations

extension Double {
    /// roundToPlaces, rounds the double to decimal places value
    func roundToPlaces(places:Int) -> Double {
      let divisor = pow(10.0, Double(places))
      return round(self * divisor) / divisor
    }
  }

// Operators to use in the switch statement.
public func ~=(lhs: (String, Int, String?), rhs: (String, Int, String?)) -> Bool {
  return lhs.0 ~= rhs.0 && lhs.1 ~= rhs.1 && lhs.2 == rhs.2
}

func ~=(lhs: (String, OperationErrorCode, String), rhs: (String, Int, String?)) -> Bool {
  return lhs.0 ~= rhs.0 && lhs.1.rawValue ~= rhs.1 && lhs.2 == rhs.2
}


/**
 This creates a new query parameters string from the given NSDictionary. For
 example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
 string will be @"day=Tuesday&month=January".
 @param queryParameters The input dictionary.
 @return The created parameters string.
 */
public func stringFromQueryParameters(queryParameters : Dictionary<String, String>) -> String {
  var parts: [String] = []
  for (name, value) in queryParameters {
    let part = NSString(format: "%@=%@", name.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!,
      value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
    parts.append(part as String)
  }
  return parts.joinWithSeparator("&")
}

/**
 Creates a new URL by adding the given query parameters.
 @param URL The input URL.
 @param queryParameters The query parameter dictionary to add.
 @return A new NSURL.
 */
public func NSURLByAppendingQueryParameters(URL : NSURL!, queryParameters : Dictionary<String, String>) -> NSURL {
  let URLString : NSString = NSString(format: "%@?%@", URL.absoluteString, stringFromQueryParameters(queryParameters))
  return NSURL(string: URLString as String)!
}
