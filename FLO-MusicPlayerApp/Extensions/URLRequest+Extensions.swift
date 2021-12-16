//
//  URLRequest+Extensions.swift
//  FLO-MusicPlayerApp
//
//  Created by 재영신 on 2021/12/16.
//

import Foundation
import RxSwift

extension URLRequest {
    static func load(_ url: URL) -> Observable<Music> {
        
        return Observable.just(url)
            .flatMap { url -> Observable<Data> in
                let request = URLRequest(url: url)
                return URLSession.shared.rx.data(request: request)
            }.map { data -> Music in
                return try JSONDecoder().decode(Music.self, from: data)
            }
        
    }
}
