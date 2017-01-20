//
//  XBImageManager.swift
//  XBImageBrowser_swift
//
//  Created by xxb on 2017/1/19.
//  Copyright © 2017年 xxb. All rights reserved.
//

import UIKit

class XBImageManager: NSObject {
    
    // MARK: - 生命周期
    
    /// 单例
    static let shared = XBImageManager()
    override init() {}
    
    
    
    // MARK: - 懒加载
    
    /// 缓存数组，缓存本次启动app用到的图片到内存提高效率
    private lazy var dicM_tempImage:[String:UIImage] = {
        return [String:UIImage]()
    }()

    /// 存储url（key）和图片本地路径Path的对应关系
    private lazy var dicM_pathForUrl:[String:String] = {
        var dic = NSKeyedUnarchiver.unarchiveObject(withFile: XBImageBorwserConfig.kDicM_pathForUrlStorePath)
        if dic == nil
        {
            dic = [String:String]()
        }
        return dic as! [String : String]
    }()
    
    private func postNotiWith(urlStr:String,image:UIImage?) -> Void {
        let finishObj = ImageFinishDownloadObj()
        finishObj.urlStr=urlStr
        finishObj.image=image
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:XBImageBorwserConfig.kNotice_imageFinishDownload), object: finishObj)
    }
    
    // 用于保存缓存图片的key（dicM_tempImage 的key）
    private var tempImgKey:String?
    
    // MARK: - 实例方法
    
    /// 获取图片 本地不存在 -> 网络请求，下载完成后
    func getImageWith(urlStr:String) {
        
        DispatchQueue.global().async {
            objc_sync_enter(self)
            
            self.tempImgKey = urlStr
            
            var result:UIImage?
            
            //从本地缓存字典中查找是否有改urlStr对应的图片
            result = self.dicM_tempImage[urlStr]
            if result != nil
            {
                self.postNotiWith(urlStr: urlStr, image: result)
                objc_sync_exit(self)
                return
            }
            
            //假设为本地文件的path，判断urlStr本地是否有该文件
            result = self.getImageWithlocalPath(path: urlStr)
            if result != nil
            {
                self.postNotiWith(urlStr: urlStr, image: result)
                objc_sync_exit(self)
                return
            }
            
            //判断dicM_pathForUrl对应的path的文件是否存在
            let fileSaveName = self.dicM_pathForUrl[urlStr]
            if fileSaveName != nil
            {
                let path = XBImageBorwserConfig.kDownloadImgStoreFullPath + "/" + fileSaveName!
                result = self.getImageWithlocalPath(path: path)
                if result != nil
                {
                    self.postNotiWith(urlStr: urlStr, image: result)
                    objc_sync_exit(self)
                    return
                }
            }
            
            /// 从url请求图片
            self.getImageWithUrlstr(urlStr: urlStr)
            
            objc_sync_exit(self)
        }
    }

    /// 从url请求图片
    private func getImageWithUrlstr(urlStr:String) -> Void
    {
        let url = URL(string: urlStr)
        if url != nil
        {
            var data:Data?
            do
            {
                data = try Data(contentsOf: url!)
            }catch{}
            
            if data != nil {
                let imgData = UIImageJPEGRepresentation(UIImage(data: data!)!, XBImageBorwserConfig.kImageQuality)
                if imgData != nil
                {
                    let image = UIImage(data: imgData!)
                    dicM_tempImage[urlStr]=image
                    
                    
                    //如果存储图片的文件夹不存在则创建
                    if FileManager.default.fileExists(atPath: XBImageBorwserConfig.kDownloadImgStoreFullPath) == false
                    {
                        do
                        {
                            try FileManager.default.createDirectory(atPath: XBImageBorwserConfig.kDownloadImgStoreFullPath, withIntermediateDirectories: true, attributes: nil)
                        }catch{}
                    }
                    
                    //保存图片到某个path、保存url和path的映射到dicM_pathForUrl
                    //以时间戳命名
                    let imageName = "\(XBImageBorwserConfig.getCurrentTimeInterval())"
                    let savePath = XBImageBorwserConfig.kDownloadImgStoreFullPath + "/" + imageName
                    
                    do
                    {
                        try imgData!.write(to: URL(fileURLWithPath: savePath))
                    }catch{}
                    
                    dicM_pathForUrl[urlStr]=imageName
                    saveData()
                    
                    postNotiWith(urlStr: urlStr, image: image)
                }
            }
 
        }
    }

    
    /// 从本地读取图片
    private func getImageWithlocalPath(path:String) -> UIImage? {

        var tempData:Data?
        
        do{
            tempData = try Data(contentsOf: URL(fileURLWithPath: path))
        }
        catch{}
        
        if tempData != nil
        {
            var image:UIImage? = UIImage(data: tempData!)
            if image != nil
            {
                var imageData = UIImageJPEGRepresentation(image!, XBImageBorwserConfig.kImageQuality)
                print("图片大小\((imageData?.count)! / 1024)KB")
                image = UIImage(data: imageData!)
                
                dicM_tempImage[tempImgKey!]=image
                return image
            }
            else
            {
                return nil
            }
        }
        else
        {
            return nil
        }
    }

    /// 保存图片和路径对应列表
    private func saveData() -> Void {
        NSKeyedArchiver.archiveRootObject(dicM_pathForUrl, toFile: XBImageBorwserConfig.kDicM_pathForUrlStorePath)
    }
    
    /// 移除对应路径的缓存图片，节约内存
    func removeImagesFromTempDictWith(arr_urlStrOrPath:[String]) -> Void {
        for str in arr_urlStrOrPath {
            dicM_tempImage.removeValue(forKey: str)
        }
    }
}
