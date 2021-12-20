//
//  String+Extensions.swift
//  FLO-MusicPlayerApp
//
//  Created by 재영신 on 2021/12/17.
//

import Foundation

extension String {
    func tolyricTime() -> Double {
        var str = self
        str.removeAll { $0 == "[" || $0 == "]"}
        var splitStr = str.split(separator: ":")
        var result = 0.0
        result += (Double(splitStr[0]) ?? 0) * 60.0
        result += (Double(splitStr[1]) ?? 0)
        result += (Double(splitStr[2]) ?? 0) / 1000.0
        return result
    }
}
