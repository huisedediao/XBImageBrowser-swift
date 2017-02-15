//
//  XBImageBrowserConfig.swift
//  XBImageBrowser_swift
//
//  Created by xxb on 2017/1/19.
//  Copyright © 2017年 xxb. All rights reserved.
//

import Foundation
import UIKit

typealias CreateLoadingViewBlockType = () ->UIView

class XBImageBorwserConfig: NSObject {

    static let ScreenWidth = UIScreen.main.bounds.size.width
    static let ScreenHeight = UIScreen.main.bounds.size.height
    
    static let kImageQuality:CGFloat = 0.5
    
    /// 返回小的值作为宽
    static var ScreenWidthMin:CGFloat { return ScreenWidth < ScreenHeight ? ScreenWidth : ScreenHeight }
    /// 返回大的值作为高
    static var ScreenHeightMax:CGFloat { return ScreenWidth > ScreenHeight ? ScreenWidth : ScreenHeight }
    

    static let kNotice_currentImageIndexChange = "kNotice_currentImageIndexChange"
    static let kNotice_itemImageClicked = "kNotice_itemImageClicked"
    static let kNotice_itemImageDeleted = "kNotice_itemImageDeleted"
    static let kNotice_imageFinishDownload = "kNotice_imageFinishDownload"
    static let kNotice_deviceOrientationWillChange = "kNotice_deviceOrientationWillChange"
    
    /// 获取当前时间戳 (NSTimeInterval)
    class func getCurrentTimeInterval() ->TimeInterval {
        return Date(timeIntervalSinceNow: 0).timeIntervalSince1970
    }
    
    /// 获取当前屏幕方向的size
    class func getRightSize() ->CGSize {
        var result:CGSize!
        let orientation = UIDevice.current.orientation
        if orientation == UIDeviceOrientation.landscapeLeft || orientation == UIDeviceOrientation.landscapeRight
        {
            result = CGSize(width: ScreenHeightMax, height: ScreenWidthMin)
        }
        else
        {
            result = CGSize(width: ScreenWidthMin, height: ScreenHeightMax)
        }
        return result
    }
    
    static let kDicM_pathForUrlStorePath = NSHomeDirectory() + "/Documents/KdicM_pathForUrlStorePath"
    static let kDownloadImgStoreFullPath = NSHomeDirectory() + "/Documents/KdownloadImgStorePath"

}

class ImageFinishDownloadObj: NSObject {
    var urlStr:String?
    var image:UIImage? 
    
}
