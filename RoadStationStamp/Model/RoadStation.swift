//
//  RoadStation.swift
//  RoadStationStamp
//
//  Created by 藤森太暉 on 2022/08/24.
//

import Foundation
import CoreLocation




struct RoadStation: Equatable,Codable{
    
    
    
    
    static func == (lhs: RoadStation, rhs: RoadStation) -> Bool {
        return lhs.name == rhs.name
    }
    
    var name : String
    var latitude : Double
    var longitude : Double
    var address : String
    var url : String
    var area : String
    var ken : String
    var isStamp : Bool = false
    var memeries : [Memory]? = nil
    
   
  
    
}

    // 配列をuserdefaultsの保存
    func saveStationsArray (stations: [RoadStation]) {
        let encoder = JSONEncoder()
        
        guard let data = try? encoder.encode(stations) else {
            return
        }
        UserDefaults.standard.set(data, forKey: "stations")
    }

    func saveStationsDictionary (dictionary : [String : [String : [RoadStation]]]) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(dictionary) else {
            return
        }
        UserDefaults.standard.set(data, forKey: "stationDic")
    }
    
    // userdefaultsの配列を取得し返す
    func loadStationsArray () -> [RoadStation]? {
        let decoder = JSONDecoder()
        guard let data = UserDefaults.standard.data(forKey: "stations"),
              let stations = try? decoder.decode([RoadStation].self, from: data) else {
            return nil
        }
//        print("loadStations\(stations)")
        return stations
    }

//    func loadStationsDictionary () -> [String : [String: [RoadStation]]]? {
//        let decoder = JSONDecoder()
//        guard let data = UserDefaults.standard.data(forKey: "stationDic"),
//              let stationDic = try? decoder.decode([String: [String : [RoadStation]]].self,
//                                                   from: data) else {
//                  return nil
//              }
//        return stationDic
//    }
//
//func arrayFromDict (dictionary: [String: [String : [RoadStation]]]) -> [RoadStation]{
//    var stations = [RoadStation]()
//    for kenValue in dictionary.values {
//        for value in kenValue.values {
//            stations.append(contentsOf: value)
//        }
//    }
//
//    return stations
//}



    
//}
