//
//  Music.swift
//  FLO-MusicPlayerApp
//
//  Created by 재영신 on 2021/12/16.
//

import Foundation


struct Music: Decodable {
    let singer: String
    let album: String
    let title: String
    let duration: Int
    let image: String /// 이미지 url
    let file: String /// music file url
    let lyrics: String /// 시간에 대한 재생되는 가사
}
