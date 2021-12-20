//
//  TimeInterval+Extensions.swift
//  FLO-MusicPlayerApp
//
//  Created by 재영신 on 2021/12/20.
//

import Foundation


extension Int {
    func toMusicString() -> String {
        let min = self/60
        let sec = self%60
        
        return String(format: "%02d:%02d", min,sec)
    }
}
