import CoreGraphics
import PDFKit
import UIKit

struct PdfPageContent {
    var pageIndex = 0
    var  text = ""
    var images:[UIImage]?
}
/// PDF图片提取工具类（最终可用版）
enum PDFImageExtractor {
    
    /// 从PDF提取图片和文本
    /// - Parameters:
    ///   - pdfURL: pdf的url地址
    ///   - pageIndex: pgeindex，从1开始,如果传0，是获取所有page
    /// - Returns: 文本和图片，还的错误码
    static func extractAllImages(from pdfURL: URL, pageIndex: Int) -> Result<[PdfPageContent], XError> {
        guard let pdfDocument = loadPDFDocument(from: pdfURL) else {
            print("❌ 无法加载PDF文档或文档已加密")
            return .failure(XError(msg: "❌ 无法加载PDF文档或文档已加密", code: -1))
        }
        guard let pdf = PDFDocument(url: pdfURL) else { return .failure(XError(msg: "❌ 无法加载PDF文档或文档已加密", code: -1)) }
        
        
        var pdfContents = [PdfPageContent]()
        let totalPages = pdfDocument.numberOfPages
        print("一共有\(totalPages)页面")
        for pageNumber in 1 ... totalPages { // 貌似pdfDocument.page(at:是从1开始的，但是pdf.page(at: 是从0开始的
            if pageNumber != pageIndex && pageIndex > 0 {
                continue
            }
           
            guard let pdfPage = pdfDocument.page(at: pageNumber) else {
                print("❌ 无法获取第\(pageNumber)页")
                continue
            }
            
            guard let pageResources = getPageResources(from: pdfPage) else {
                print("   ⚠️ 第\(pageNumber)页无资源信息")
                continue
            }
            
            var content = PdfPageContent()
            content.pageIndex = pageNumber
            if let page = pdf.page(at: pageNumber - 1), let pageText = page.string {
                content.text = pageText
            }
            let pageImages = extractImages(from: pageResources)
            content.images = pageImages
            print("📄 第\(pageNumber)/\(totalPages)页提取到\(pageImages.count)张图片")
            pdfContents.append(content)
        }
        return .success(pdfContents)
    }
    
    // MARK: - 获取页面资源

    private static func getPageResources(from page: CGPDFPage) -> CGPDFDictionaryRef? {
        guard let pageDict = page.dictionary else {
            print("   ❌ 无法获取页面字典")
            return nil
        }
        
        var resources: CGPDFDictionaryRef?
        let hasResources = CGPDFDictionaryGetDictionary(pageDict, "Resources", &resources)
        return hasResources ? resources : nil
    }
    
    // MARK: - 提取图片核心逻辑

    private static func extractImages(from resources: CGPDFDictionaryRef) -> [UIImage] {
        var extractedImages: [UIImage] = []
        
        guard let xObjectDictionary = getXObjectDictionary(from: resources) else {
            print("   ⚠️ 未找到XObject字典")
            return []
        }
        
        // 传递图片数组指针给全局回调函数
        withUnsafeMutablePointer(to: &extractedImages) { imagesPointer in
            CGPDFDictionaryApplyFunction(
                xObjectDictionary,
                pdfDictionaryCallback, // 使用全局C函数
                UnsafeMutableRawPointer(imagesPointer)
            )
        }
        
        return extractedImages
    }
    
    // MARK: - 其他辅助方法

    private static func getXObjectDictionary(from resources: CGPDFDictionaryRef) -> CGPDFDictionaryRef? {
        var xObjectDict: CGPDFDictionaryRef?
        let hasXObject = CGPDFDictionaryGetDictionary(resources, "XObject", &xObjectDict)
        return hasXObject ? xObjectDict : nil
    }
    
    static func extractImage(from pdfObject: CGPDFObjectRef) -> UIImage? {
        guard let pdfStream = getStream(from: pdfObject) else {
            print("   ❌ 无法转换为流对象")
            return nil
        }
        
        guard isImageStream(pdfStream) else {
            return nil
        }
        
        return convertStreamToImage(pdfStream)
    }
    
    private static func getStream(from pdfObject: CGPDFObjectRef) -> CGPDFStreamRef? {
        var stream: CGPDFStreamRef?
        withUnsafeMutablePointer(to: &stream) {
            CGPDFObjectGetValue(pdfObject, .stream, $0)
        }
        return stream
    }
    
    private static func isImageStream(_ stream: CGPDFStreamRef) -> Bool {
        guard let streamDictionary = getStreamDictionary(from: stream) else {
            print("   ❌ 流无属性字典")
            return false
        }
        
        guard let subtype = getStreamSubtype(from: streamDictionary),
              subtype == "Image"
        else {
            return false
        }
        
        return true
    }
    
    private static func getStreamDictionary(from stream: CGPDFStreamRef) -> CGPDFDictionaryRef? {
        var dictionary = CGPDFStreamGetDictionary(stream)
        return dictionary
    }
    
    private static func getStreamSubtype(from streamDictionary: CGPDFDictionaryRef) -> String? {
        var subtypeObject: CGPDFObjectRef?
        CGPDFDictionaryGetObject(streamDictionary, "Subtype", &subtypeObject)
        guard let subtypeObject = subtypeObject else {
            print("   ❌ 流无Subtype属性")
            return nil
        }
        
        guard CGPDFObjectGetType(subtypeObject) == .name else {
            print("   ❌ Subtype不是名称类型")
            return nil
        }
        
        var subtypeNamePointer: UnsafePointer<CChar>?
        withUnsafeMutablePointer(to: &subtypeNamePointer) {
            CGPDFObjectGetValue(subtypeObject, .name, $0)
        }
        
        guard let namePointer = subtypeNamePointer else {
            print("   ❌ 无法获取Subtype值")
            return nil
        }
        
        return String(cString: namePointer)
    }
    
    private static func convertStreamToImage(_ stream: CGPDFStreamRef) -> UIImage? {
        guard let streamData = getStreamData(from: stream) else {
            print("   ❌ 无法获取流数据")
            return nil
        }
        
        guard let cgImage = createCGImage(from: streamData) else {
            print("   ❌ 无法转换为图片")
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    private static func getStreamData(from stream: CGPDFStreamRef) -> Data? {
        var dataFormat = CGPDFDataFormat.raw
        guard let data = CGPDFStreamCopyData(stream, &dataFormat) as Data?,
              !data.isEmpty
        else {
            return nil
        }
        return data
    }
    
    private static func createCGImage(from data: Data) -> CGImage? {
        guard let dataProvider = CGDataProvider(data: data as CFData) else {
            return nil
        }
        
        guard let imageSource = CGImageSourceCreateWithDataProvider(dataProvider, nil) else {
            return nil
        }
        
        return CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
    }
    
    private static func loadPDFDocument(from url: URL) -> CGPDFDocument? {
        guard let pdfDocument = CGPDFDocument(url as CFURL) else {
            return nil
        }
        return pdfDocument.isEncrypted ? nil : pdfDocument
    }
}

// MARK: - 全局C风格回调函数（关键修复）

/// 必须定义为全局函数才能作为C函数指针
private func pdfDictionaryCallback(
    key: UnsafePointer<CChar>,
    value: CGPDFObjectRef,
    info: UnsafeMutableRawPointer?
) {
    // 将info指针转换为图片数组
    guard let imagesPointer = info?.assumingMemoryBound(to: [UIImage].self) else {
        return
    }
    
    let resourceName = String(cString: key)
    
    // 只处理流类型对象
    guard CGPDFObjectGetType(value) == .stream else {
        print("   ⚠️ 资源\(resourceName)不是流对象，跳过")
        return
    }
    
    // 调用工具类的方法提取图片
    if let image = PDFImageExtractor.extractImage(from: value) {
        imagesPointer.pointee.append(image)
        print("   ✅ 提取图片：\(resourceName)")
    }
}

// MARK: - 使用示例

/*
 if let pdfURL = Bundle.main.url(forResource: "example", withExtension: "pdf") {
     let images = PDFImageExtractor.extractAllImages(from: pdfURL)
     // 使用提取的图片
 }
 */
