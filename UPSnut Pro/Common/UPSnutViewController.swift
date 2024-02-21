//
//  UPSnutViewController.swift
//  UPSnut Pro
//
//  Created by Ioan Moldovan on 27.07.2022.
//

import UIKit

class UPSnutViewController: UITabBarController {
    
    @IBAction func refreshWasClicked(_ sender: Any) {
    
        if (self.selectedViewController is APCViewController)
        {
            (self.selectedViewController as! APCViewController).refreshCommand(sender)
        }
        
        else if (self.selectedViewController is NUTViewController)
        {
            (self.selectedViewController as! NUTViewController).refreshCommand(sender)
        }

    }
    

    @IBAction func addWasClicked(_ sender: Any) {
        if (self.selectedViewController is APCViewController)
        {
            (self.selectedViewController as! APCViewController).addCommand(sender)
        }
        
        else if (self.selectedViewController is NUTViewController)
        {
            (self.selectedViewController as! NUTViewController).addCommand(sender)
        }
    }
    
}

