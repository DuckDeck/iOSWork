import UIKit
@objc public extension UIFont {
    static func if_iconFont(_ size: CGFloat) -> UIFont {
        var font = UIFont(name: "iconfont", size: size)
        if font == nil {
            self.dynamicallyLoadFont()
            font = UIFont(name:"iconfont", size: size)
        }
        return font ?? UIFont.systemFont(ofSize: size)
    }

    @discardableResult
    static func dynamicallyLoadFont() -> Bool {
        let bundle = Bundle(path: Bundle.main.bundlePath.appending("/Frameworks/BBIconFont.framework/BBIconFont.bundle"))
        guard let filePath = bundle?.bundlePath.appending("/iconfont.ttf") else { return false }

        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else { return false }
        guard let provider = CGDataProvider(data: data as CFData) else { return false }
        guard let font = CGFont(provider) else { return false }
        if !CTFontManagerRegisterGraphicsFont(font, nil) {
            return false
        }
        return true
    }
}
