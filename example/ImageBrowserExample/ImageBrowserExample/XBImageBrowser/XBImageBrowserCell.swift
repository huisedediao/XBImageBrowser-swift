//
//  XBImageBrowserCell.swift
//  XBImageBrowser_swift
//
//  Created by xxb on 2017/1/19.
//  Copyright © 2017年 xxb. All rights reserved.
//

import UIKit

class XBImageBrowserCell: UICollectionViewCell {
    
    var str_imagePathOrUrlstr:String? {
        didSet{
            item.str_imagePathOrUrlstr = str_imagePathOrUrlstr
        }
    }
    
    var index:Int=0 {
        didSet{
            item.int_index = index
        }
    }
    
    var item:XBImageBrowserItem = {
        let item = XBImageBrowserItem(frame: CGRect(x: 0, y: 0, width: XBImageBorwserConfig.ScreenWidth, height: XBImageBorwserConfig.ScreenHeight))
        return item
    }()
    
    /** 创建等待view的block，如果没有设置则默认为菊花 */
    var createLoadingViewBlcok:CreateLoadingViewBlockType?{
        didSet{
            item.createLoadingViewBlcok = createLoadingViewBlcok
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(item)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
