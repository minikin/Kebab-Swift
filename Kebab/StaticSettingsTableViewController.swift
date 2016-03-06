//
//  StaticSettingsTableViewController.swift
//  Kebab
//
//  Created by Sasha Prokhorenko on 10/21/15.
//  Copyright © 2015 Minikin. All rights reserved.
//

import UIKit


class StaticSettingsTableViewController : UITableViewController {
  
  @IBOutlet weak var searchCell: UITableViewCell!
  @IBOutlet weak var openCell: UITableViewCell!
  @IBOutlet weak var categoriesCell: UITableViewCell!
  @IBOutlet weak var openSwitch: UISwitch!
  @IBOutlet weak var aboutCell: UITableViewCell!
  @IBOutlet weak var teamCell: UITableViewCell!
  @IBOutlet weak var mapBoxCell: UITableViewCell!
  @IBOutlet weak var foursquareCell: UITableViewCell!
  
  // Create view to draw the line bellow navigation bar
  var lineView: UIView = UIView(frame: CGRectMake(0,0,0,0))
  
  //
  let defaults = NSUserDefaults.standardUserDefaults()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.titleView = UIImageView(image: UIImage(named: "kebab"))
    let backItem = UIBarButtonItem(title: "", style:.Plain, target: nil, action: nil)
    navigationItem.backBarButtonItem = backItem
    
    tableView.backgroundColor = Theme.Background.mainColor
    tableView.separatorColor = Theme.Lines.mainColor
    tableView.sectionHeaderHeight = 40
    tableView.sectionFooterHeight = 20
    self.clearsSelectionOnViewWillAppear = true
    
    searchCell.backgroundColor = Theme.Background.mainColor
    openCell.backgroundColor = Theme.Background.mainColor
    categoriesCell.backgroundColor = Theme.Background.mainColor
    aboutCell.backgroundColor = Theme.Background.mainColor
    teamCell.backgroundColor = Theme.Background.mainColor
    mapBoxCell.backgroundColor = Theme.Background.mainColor
    foursquareCell.backgroundColor = Theme.Background.mainColor
    
    
    // Check if there is a previously created SwitchState key, and if so we load the state and change the switch.
    
    if (defaults.objectForKey("SwitchState") != nil) {
      openSwitch.on = defaults.boolForKey("SwitchState")
    }
    
  
  }
  
  override func viewWillAppear(animated: Bool) {
    
    //Add line below navigationbar
    if let navigationController = self.navigationController {
      let navigationBar = navigationController.navigationBar
      let navBorder: UIView = UIView(frame: CGRectMake(0, navigationBar.frame.size.height - 1, navigationBar.frame.size.width, 1))
      // Set the color you want here
      navBorder.backgroundColor = Theme.Lines.mainColor
      navBorder.opaque = true
      lineView = navBorder
      self.navigationController?.navigationBar.addSubview(lineView)
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    // Remove line when we moving to another viewController
    lineView.removeFromSuperview()
  }
  
  override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section:Int) {
    
    let header:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
    
    header.textLabel!.textColor = Theme.Text.mainColor
    header.textLabel!.font = Theme.HelpText.textStyle

  }
  
  override func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
    let footer:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
    
    footer.textLabel!.textColor = Theme.Text.mainColor
    footer.textLabel!.font = Theme.HelpText.textStyle
  }
  
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
  }
  
  
  @IBAction func searchAllVenues(sender: AnyObject) {
    
    
    // NSUserDefaults object, where we can save the user settings
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    if openSwitch.on {
      defaults.setBool(true, forKey: "SwitchState")
    } else {
      defaults.setBool(false, forKey: "SwitchState")
    }
    
  }
  
  
}