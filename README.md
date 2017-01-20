# XBImageBrowser-swift
图片浏览器，支持本地图片和网络图片（支持混搭，虽然没什么卵用），支持屏幕旋转
</br>
使用参考oc版本：传送门[XBImageBrowser](https://github.com/huisedediao/XBImageBrowser)
</br>
如果app不支持屏幕旋转，要在appDelegate中实现以下方法
<pre>
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
</pre>