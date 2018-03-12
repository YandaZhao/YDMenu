//
//  ViewController.swift
//  YDMenu
//
//  Created by ZJXN on 2018/3/8.
//  Copyright © 2018年 YDZhao. All rights reserved.
//

import UIKit

class ViewController: UIViewController, YDMenuDataSource, YDMenuDelegate {
    
    var data = [String: AnyObject]()
    
    let menu = YDMenu(origin: CGPoint(x: 0, y: 50), menuheight: 40)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let dataUrl = Bundle.main.url(forResource: "MenuData", withExtension: "plist")
        
        if dataUrl != nil {
            data =  NSDictionary(contentsOf: dataUrl!)! as! [String : AnyObject]
        }
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        view.addSubview(menu)
        menu.delegate = self
        menu.dataSource = self
   
    }

    @IBAction func selectedBtnClick(_ sender: Any) {
        
        menu.selectedAtIndex(YDMenu.Index(column: 1, row: 2))
    }
    
    @IBAction func selectedDefaultBtnClick(_ sender: Any) {
        
        menu.selectDeafult()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - YDMenuDataSource / Delegate
    
    func numberOfColumnsInMenu(_ menu: YDMenu) -> Int {
        return data.count
    }
    
    func menu(_ menu: YDMenu, numberOfRowsInColumn column: Int) -> Int {
        
        switch column {
        case 0:
            return (data["Area"] as! [[String: AnyObject]]).count
        case 1:
            return (data["Order"] as! [String]).count
        case 2:
            return (data["sift"] as! [String]).count
        default:
            return 0
        }
    }
    
    func menu(_ menu: YDMenu, numberOfItemsInRow row: Int, inColumn column: Int) -> Int {
        if column == 0 {
            return ((data["Area"] as! [[String: AnyObject]])[row]["distance"] as! [String]).count
        }
        return 0
    }
    
    func menu(_ menu: YDMenu, titleForItemsInRowAtIndexPath indexPath: YDMenu.Index) -> String {
        
        
        switch indexPath.column {
            
        case 0:
            return ((data["Area"] as! [[String: AnyObject]])[indexPath.row]["distance"] as! [String])[indexPath.item]

                default:
            return ""
        }
        
        
    }
    
    func menu(_ menu: YDMenu, titleForRowAtIndexPath indexPath: YDMenu.Index) -> String {
        
        switch indexPath.column {
        case 0:
            return (data["Area"] as! [[String: AnyObject]])[indexPath.row]["name"] as! String
        case 1:
            return (data["Order"] as! [String])[indexPath.row]
        case 2:
            return (data["sift"] as! [String])[indexPath.row]
        default:
            return ""
        }
    }
    
    func menu(_ menu: YDMenu, imageNameForRowAtIndexPath indexPath: YDMenu.Index) -> String? {
        if indexPath.column == 0 || indexPath.column == 2 {
            return (arc4random() % 10).description
        }
        return nil
    }
    
    func menu(_ menu: YDMenu, detailTextForRowAtIndexPath indexPath: YDMenu.Index) -> String? {
        
        let random = arc4random() % 100
        return random.description
    }
    
    func menu(_ menu: YDMenu, detailTextForItemsInRowAtIndexPath indexPath: YDMenu.Index) -> String? {
        let random = arc4random() % 1000
        return random.description
    }
    
    
    func menu(_ menu: YDMenu, didSelectRowAtIndexPath indexPath: YDMenu.Index) {
        
        print("选中了第\(indexPath.column)列, 一级列表的第\(indexPath.row)行\(indexPath.haveItem ? ", 二级列表的第\(indexPath.item)行" : ", 没有选择二级列表")")
    }

}


