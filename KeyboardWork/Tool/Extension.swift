//
//  Extension.swift
//  KeyboardWork
//
//  Created by Stan Hu on 2022/4/17.
//

import Foundation



extension String{
    var participleString:([RecognizeType],[String]){
        let punctuation = ["，", "。" , "！" , "、" , "；" , "：", "？","【" , "】" , "（" , "）" ,"\n"]
        
        var words = self.count > 0 ? WGInputAssociateWraper.warp().get_split_list_(by: self) : []
        words =  words.filter { (str) -> Bool in
            return str.trimmingCharacters(in: .whitespaces).count > 0 && !punctuation.contains(str) && str != "️"
        }
        let recognizedWords = Recognize.recognize(self)
        return (recognizedWords,words)
    }
}

