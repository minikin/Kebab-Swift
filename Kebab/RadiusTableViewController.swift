//
//  RadiusTableViewController.swift
//  Kebab
//
//  Created by Sasha Minikin on 12/6/15.
//  Copyright © 2015 Minikin. All rights reserved.
//

import UIKit

class RadiusTableViewController: UITableViewController {
  
  @IBOutlet var radiusTableView: UITableView!
  @IBOutlet weak var cell1500: UITableViewCell!
  @IBOutlet weak var cell1000: UITableViewCell!
  @IBOutlet weak var cell700: UITableViewCell!
  @IBOutlet weak var cell500: UITableViewCell!
  @IBOutlet weak var cell200: UITableViewCell!
  

  // Create view to draw the line bellow navigation bar
  var lineView: UIView = UIView(frame: CGRectMake(0,0,0,0))

    override func viewDidLoad() {
        super.viewDidLoad()
      
      navigationItem.titleView = UIImageView(image: UIImage(named: "kebab"))
      
      tableView.backgroundColor = Theme.Background.mainColor
      tableView.separatorColor = Theme.Lines.mainColor
      tableView.sectionHeaderHeight = 40
      tableView.sectionFooterHeight = 20
      self.clearsSelectionOnViewWillAppear = true
      
      cell1500.imageView?.image = UIImage(named: "1500")
      cell1000.imageView?.image = UIImage(named: "1000")
      cell700.imageView?.image = UIImage(named: "700")
      cell500.imageView?.image = UIImage(named: "500")
      cell200.imageView?.image = UIImage(named: "200")
      
      cell1500.textLabel?.text = SearchRadius.one.rawValue
      cell1000.textLabel?.text = SearchRadius.two.rawValue
      cell700.textLabel?.text = SearchRadius.three.rawValue
      cell500.textLabel?.text = SearchRadius.four.rawValue
      cell200.textLabel?.text = SearchRadius.five.rawValue
      
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
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    /*
    Even though each cell is designed initially in the storyboard, I can still implementtable - cellForRowAtIndexPath:
    to call super and then add further functionality.
    That’s how I’ll add the checkmarks. The user defaults are storing the current choice categories.
    there’s a "Junkfood categories" preference consisting of a string denoting the title of the chosen cell:
    */
    
    
    let cell =  super.tableView(radiusTableView, cellForRowAtIndexPath: indexPath) as UITableViewCell
    
    // Set
    cell.accessoryType = .None
    cell.backgroundColor = Theme.Background.mainColor
    cell.textLabel?.font = Theme.RegularText.textStyle
    cell.textLabel?.textColor  = Theme.Text.mainColor
    
    let ud = NSUserDefaults.standardUserDefaults()
    if ud.valueForKey("Search radius") as? String == cell.textLabel?.text {
      cell.accessoryType = .Checkmark
    }
    
    return cell
  }
  
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    /*
    
    When the user taps a cell, the cell is selected. I want the user to see that selection mo‐ mentarily, as feedback,
    but then I want to deselect, adjusting the checkmarks so that that cell is the only one checked in its section.
    In tableView:didSelectRowAtIndex- Path:,
    I set the user defaults, and then I reload the table view’s data.
    This removes the selection and causes tableView:cellForRowAtIndexPath: to be called to adjust the checkmarks:
    
    */
    
    let ud = NSUserDefaults.standardUserDefaults()
    let settings = radiusTableView.cellForRowAtIndexPath(indexPath)!.textLabel!.text
    let header = self.tableView(radiusTableView, titleForHeaderInSection:indexPath.section)
    
    ud.setValue(settings, forKey: header!)
    
    radiusTableView.reloadData()
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
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}
