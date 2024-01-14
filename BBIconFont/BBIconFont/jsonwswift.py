import os
import json


ROOT_DIR=os.path.abspath(os.path.abspath(os.path.dirname(__file__)))
def convert2swift():
    content = buildContent()
    swiftFilePath = os.path.join(ROOT_DIR, 'Classes/BBIconNames.swift')
    with open(swiftFilePath, mode='w+') as swift_file:
        swift_file.write (content)
def buildContent():
    content = u"""//
//BBIconNames.swift
//BBIconFont
//
//Created by Y@o on 2021/6/15.


 @objcMembers

public class BBIconNames: NSObject{\n"""
    with open(os.path.join(ROOT_DIR,'Assets','iconfont', 'iconfont.json')) as json_file:
        srcData = json.load(json_file)
        glyphs = srcData["glyphs"]
        for item in glyphs:
            annotationStr = "/// icon_id: %s \n" % (item.get ("icon_id"))
            propertyStr = annotationStr + \
                        "   public static var %s = \"\\u{%s}\" \n" % (item["name"].replace('-',''),
                                                                      item["unicode"])
            content += propertyStr

    content +=   """   public override class func setValue(_ value: Any?, forUndefinedKey key: String) {
             assert(false,"未实现的属性\(key),请更新iconfont文件。")
        }
}"""
    return content
if __name__ == '__main__':
    convert2swift()
