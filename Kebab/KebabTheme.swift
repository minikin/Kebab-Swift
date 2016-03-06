//
//  KebabTheme.swift
//  Kebab
//
//  Created by Sasha Prokhorenko on 10/22/15.
//  Copyright © 2015 Minikin. All rights reserved.
//

import UIKit

enum Theme {
  
  case Background, Text, Labels, Menu, Lines, ImageHelper
  
  case RegularText, KebabText, HelpText
  
  case SPMessageSuccessBackground, SPMessageWarningBackground, SPMessageErrorBackground, SPMessageInfoBackground
  
  var mainColor: UIColor {
    switch self {
    case .Background:
      return UIColor(red: 0.13, green:0.13, blue: 0.13, alpha: 1.0)
    case .Text:
      return UIColor(red: 1.0, green:1.0, blue: 1.0, alpha: 1.0)
    case .Labels:
      return UIColor(red: 0.13, green:1.0, blue: 0.13, alpha: 1.0)
    case .Menu:
      return UIColor(red: 1.0, green:1.0, blue: 1.0, alpha: 1.0)
    case .Lines:
      return UIColor(red: 0.56, green:0.56, blue: 0.56, alpha: 1.0)
    case .ImageHelper:
      return UIColor(red: 34/255, green: 255/255, blue: 34/255, alpha: 1.0)
    default:
      return UIColor(red: 0.13, green:0.13, blue: 0.13, alpha: 1.0)
    }
  }
  
  var textStyle: UIFont {
    switch self {
    case .RegularText:
      return UIFont(name: "SanFranciscoDisplay-Light", size: 18)!
    case .KebabText:
      return UIFont(name: "Basetica-Med", size: 30)!
    case .HelpText:
      return UIFont(name: "SanFranciscoDisplay-Light", size: 15)!
    default:
      return UIFont(name: "SanFranciscoDisplay-Light", size: 15)!
    }
  }
  
  var SPMessageStyle: UIColor {
    switch self {
    case .SPMessageSuccessBackground:
      return UIColor(red: 142.0/255, green: 183.0/255, blue: 64.0/255, alpha: 1.0)
    case   .SPMessageWarningBackground:
      return UIColor(red: 245.0/255, green: 166.0/255, blue: 35.0/255, alpha: 1.0)
    case .SPMessageErrorBackground:
      return UIColor(red: 208.0/255, green: 2.0/255, blue: 27.0/255, alpha: 1.0)
    case .SPMessageInfoBackground:
      return UIColor(red: 126.0/255, green: 211.0/255, blue: 33.0/255, alpha: 1.0)
    default:
      return UIColor(red: 245.0/255, green: 166.0/255, blue: 35.0/255, alpha: 1.0)
    }
  }
  
}