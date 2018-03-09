//
//  YDMenuDelegate.swift
//  YDMenu
//
//  Created by ZJXN on 2018/3/8.
//  Copyright © 2018年 YDZhao. All rights reserved.
//

import Foundation

protocol YDMenuDelegate: class {
    
    /// 点击
    func menu(_ menu: YDMenu, didSelectRowAtIndexPath indexPath: YDMenu.Index) -> Void
}

