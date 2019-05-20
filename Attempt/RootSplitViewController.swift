//
//  RootSplitViewController.swift
//  Attempt
//
//  Created by Vaibhav Maheshwari on 24/03/19.
//  Copyright © 2019 Learning. All rights reserved.
//

import UIKit
import WCLShineButton

class RootSplitViewController: UISplitViewController {
    
    var bt1: WCLShineButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var param1 = WCLShineParams()
        param1.bigShineColor = UIColor(rgb: (255, 211, 81))
        param1.smallShineColor = UIColor(rgb: (247, 161, 64))
        bt1 = WCLShineButton(frame: .init(x: 100, y: 100, width: 60, height: 60))
        bt1.translatesAutoresizingMaskIntoConstraints = false
        bt1.fillColor = UIColor(rgb: (153,152,38))
        bt1.color = UIColor(rgb: (170,170,170))
        bt1.image = WCLShineImage.star
        bt1.addTarget(self, action: #selector(action), for: .valueChanged)
        
        let tabBarControllerView: UIView = (viewControllers[1] as! UITabBarController).view
        tabBarControllerView.addSubview(bt1)
        bt1.centerXAnchor.constraint(equalTo: tabBarControllerView.centerXAnchor).isActive = true
        bt1.widthAnchor.constraint(equalToConstant: 60).isActive = true
        bt1.heightAnchor.constraint(equalToConstant: 60).isActive =  true
        tabBarControllerView.readableContentGuide.bottomAnchor.constraint(equalTo: bt1.bottomAnchor, constant: 30).isActive = true
        
    }
    
    @objc func action() {
        //check current word and mark it as favourite
        if (bt1.isSelected) {
            ((viewControllers[0] as! UINavigationController).viewControllers[0] as! MasterViewController).addFavourite()
        } else {
             ((viewControllers[0] as! UINavigationController).viewControllers[0] as! MasterViewController).removeFavourite()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
