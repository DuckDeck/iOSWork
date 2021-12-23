#  使用命令创建XCFramework
```swift
# -- 针对.a --
# 指令：
xcodebuild -create-xcframework -library <path> [-headers <path>] [-library <path> [-headers <path>]...] -output <path>
# 样例：
xcodebuild -create-xcframework -library youpath/TestFramework.a -headers youpath/TestFramework -library youpath/TestFramework.a -headers youpath/TestFramework -output youpath/TestFramework.xcframewor/Users/stanhu/Desktop/Git/iOSWork/ConsoleWork/iOS开发技巧/README.mdk

# -- 针对.framework --
# 指令：
xcodebuild -create-xcframework -framework <path> [-framework <path>...] -output <path>
# 样例：
xcodebuild -create-xcframework -framework Release-iphoneos/TestFramework.framework -framework Release-iphonesimulator/TestFramework.framework -output TestFramework.xcframework

```

