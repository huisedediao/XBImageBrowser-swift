//
//  XBImageBrowserItem.swift
//  XBImageBrowser_swift
//
//  Created by xxb on 2017/1/19.
//  Copyright © 2017年 xxb. All rights reserved.
//

import UIKit

class XBImageBrowserItem: UIView {
    
    // MARK: - 懒加载
    fileprivate lazy var scrollView:UIScrollView = {
        let _scrollView = UIScrollView()
        _scrollView.delegate = self
        _scrollView.maximumZoomScale = 5.0;//最大缩放倍数
        _scrollView.minimumZoomScale = 1.0;//最小缩放倍数
        _scrollView.showsVerticalScrollIndicator = false;
        _scrollView.showsHorizontalScrollIndicator = false;
        _scrollView.backgroundColor = UIColor.clear
        return _scrollView
    }()
    
    fileprivate lazy var imageView:UIImageView = {
        let _imageView = UIImageView()
        _imageView.isUserInteractionEnabled = true
        
        //添加双击手势
        let doubleTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(recongnizer:)))
        doubleTap.numberOfTapsRequired = 2
        _imageView.addGestureRecognizer(doubleTap)
        
        //添加单击手势
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(tap:)))
        _imageView.addGestureRecognizer(tap)
        
        //单击手势在双击没起作用时才起作用
        tap.require(toFail: doubleTap)
        return _imageView
    }()
    
    fileprivate lazy var activityView:UIActivityIndicatorView = {
        let _activityView = UIActivityIndicatorView()
        _activityView.center=self.center
        _activityView.startAnimating()
        return _activityView
    }()
    
    
    /** 记录cell的序号，在cell不显示时将item的scrollView的缩放倍数还原 */
    var int_index:Int = 0 {
        didSet{
            // 这里或者str_imagePathOrUrlstr didSet中更新frame，避免屏幕翻转，collectionView重新载入数据，没有更新frame
            updateSubviewsFrame()
        }
    }
    var str_imagePathOrUrlstr:String? {
        didSet{
            if str_imagePathOrUrlstr != nil
            {
                //避免本地图片太大(不管本地或者网络)，滑动到下一次cell复用，仍然显示上一张图片
                self.imageView.frame = CGRect.zero
                activityView.startAnimating()
                
                XBImageManager.shared.getImageWith(urlStr: str_imagePathOrUrlstr!)
            }
        }
    }
    
    private var image:UIImage? {
        didSet{
            if self.image != nil {
                activityView.stopAnimating()
                self.imageView.image = image;
                var width = image!.size.width;
                var height = image!.size.height;
                let maxHeight = self.scrollView.bounds.size.height;
                let maxWidth = self.scrollView.bounds.size.width;
                //如果图片尺寸大于view尺寸，按比例缩放
                if(width > maxWidth || height > width)
                {
                    let ratio = height / width;
                    let maxRatio = maxHeight / maxWidth;
                    if(ratio < maxRatio)
                    {
                        width = maxWidth;
                        height = width*ratio;
                    }
                    else
                    {
                        height = maxHeight;
                        width = height / ratio;
                    }
                }
                imageView.frame = CGRect(x: (maxWidth - width) / 2, y: (maxHeight - height) / 2, width: width, height: height)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addNotice()
        configSubViews()
        scrollView.frame = bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeNotice()
    }
    
    private func configSubViews() -> Void {
        addSubview(scrollView)
        scrollView.addSubview(imageView)
        addSubview(activityView)
    }
    
    
    // MARK: - 通知相关
    
    private func addNotice() -> Void {
        
        //添加通知获取设备发生旋转时的相关信息
        NotificationCenter.default.addObserver(self, selector: #selector(self.deviceOrientationDidChange(notification:)), name: NSNotification.Name(rawValue:XBImageBorwserConfig.kNotice_deviceOrientationWillChange), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.currentImageIndexChanged(noti:)), name: NSNotification.Name(rawValue:XBImageBorwserConfig.kNotice_currentImageIndexChange), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.imageFinishDownload(noti:)), name: NSNotification.Name(rawValue:XBImageBorwserConfig.kNotice_imageFinishDownload), object: nil)
    }
    
    private func removeNotice() -> Void {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:XBImageBorwserConfig.kNotice_currentImageIndexChange), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:XBImageBorwserConfig.kNotice_imageFinishDownload), object: nil)
    }
    
    
    func currentImageIndexChanged(noti:Notification) -> Void {
        if noti.object as! Int == int_index
        {
            scrollView.zoomScale = 1.0
        }
    }
    
    
    func deviceOrientationDidChange(notification:Notification) -> Void {
        let currentOrientation = UIDevice.current.orientation
        if currentOrientation != UIDeviceOrientation.faceDown && currentOrientation != UIDeviceOrientation.faceUp && currentOrientation != UIDeviceOrientation.portraitUpsideDown && currentOrientation != UIDeviceOrientation.unknown
        {
            DispatchQueue.main.async {
                self.updateSubviewsFrame()
                let image = self.image
                self.image = image
            }
        }
    }
    
    func imageFinishDownload(noti:Notification) -> Void {
        let obj = noti.object as! ImageFinishDownloadObj
        if obj.urlStr == str_imagePathOrUrlstr
        {
            DispatchQueue.main.async(execute: {
                self.image = obj.image
            })
        }
    }
    
    
    private func updateSubviewsFrame() -> Void {

        frame = CGRect(x: 0, y: 0, width: XBImageBorwserConfig.getRightSize().width, height: XBImageBorwserConfig.getRightSize().height)
        self.scrollView.frame=self.bounds;
        self.scrollView.zoomScale=1.0;
        self.activityView.center=self.center;
    }
    

    

    
    
    // MARK: - 手势处理
    
    func handleTap(tap:UITapGestureRecognizer) -> Void {
        NotificationCenter.default.post(name: NSNotification.Name(XBImageBorwserConfig.kNotice_itemImageClicked), object: image)
    }
    
    func handleDoubleTap(recongnizer:UITapGestureRecognizer) -> Void {
        let state = recongnizer.state
        
        switch (state){
        
        case .began:
            break;
        case .changed:
            break;
        case .cancelled,.ended:
            
            //以点击点为中心，放大图片
            let touchPoint = recongnizer.location(in: recongnizer.view)
            let zoomOut = scrollView.zoomScale == scrollView.minimumZoomScale
            let scale = zoomOut ? scrollView.maximumZoomScale : scrollView.minimumZoomScale
            UIView.animate(withDuration: 0.3, animations: {
                self.scrollView.zoomScale = scale;
                if(zoomOut)
                {
                    var x = touchPoint.x * scale - self.scrollView.bounds.size.width * 0.5
                    let maxX = self.scrollView.contentSize.width-self.scrollView.bounds.size.width
                    let minX:CGFloat = 0
                    x = x > maxX ? maxX : x;
                    x = x < minX ? minX : x;
                    
                    var y = touchPoint.y * scale-self.scrollView.bounds.size.height * 0.5
                    let maxY = self.scrollView.contentSize.height-self.scrollView.bounds.size.height
                    let minY:CGFloat = 0
                    y = y > maxY ? maxY : y;
                    y = y < minY ? minY : y;
                    self.scrollView.contentOffset = CGPoint(x: x, y: y)
                }
            })
            break;
            
        default:break;
        }
    }
}

extension XBImageBrowserItem:UIScrollViewDelegate {
    
    //指定缩放UIScrolleView时，缩放UIImageView来适配
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    //缩放后让图片显示到屏幕中间
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let originalSize = scrollView.bounds.size;
        let contentSize = scrollView.contentSize;
        let offsetX = originalSize.width > contentSize.width ? (originalSize.width - contentSize.width) / 2 : 0;
        let offsetY = originalSize.height > contentSize.height ? (originalSize.height - contentSize.height) / 2 : 0;
        self.imageView.center = CGPoint(x: contentSize.width / 2 + offsetX, y: contentSize.height / 2 + offsetY)
    }
    
}
