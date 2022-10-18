//
//  Memory.swift
//  RoadStationStamp
//
//  Created by 藤森太暉 on 2022/10/12.
//

import Foundation
import UIKit


//各、道の駅での思い出を管理するモデル
struct Memory : Codable{
    //日付を格納
    var date : Date?
    // 文章を格納
    var text : String?
    // 写真動画を格納
    // 写真なら4枚まで、動画は一つまで
//    var media : [UIImage]?
    
    
}

//extension Memory : Codable {
//    enum CodingKeys: String, CodingKey {
//        case date
//        case text
//        case media
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        date = try values.decode(Date.self, forKey: .date)
//        text = try values.decode(String.self, forKey: .text)
//
//        let imageDataBase64String = try values.decode(String.self, forKey: .media)
//        if let data = Data(base64Encoded: imageDataBase64String) {
//            media = [UIImage(data: data)!]
//        } else {
//            media = nil
//        }
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(date, forKey: .date)
//        try container.encode(text, forKey: .text)
//
//        if let image = media, let imageData = UIImagePNGRepresentation(media) {
//            let imageDataBase64String = imageData.base64EncodedString()
//            try container.encode(imageDataBase64String, forKey: .media)
//        }
//    }
//}
//
//
//
