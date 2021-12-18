//
//  APIService.swift
//  FLO-MusicPlayerApp
//
//  Created by 재영신 on 2021/12/17.
//

import Foundation
import RxSwift
import RxCocoa

class FLOAPIService {
    static func fetchMusic(_ url: URL) -> Observable<Music> {
        return Observable<URL>.just(url)
            .flatMap { url -> Observable<(response: HTTPURLResponse, data: Data)> in
                let request = URLRequest(url: url)
                return URLSession.shared.rx.response(request: request)
            }.map { response,data -> Music in
                if 200 ..< 300 ~= response.statusCode {
                    return try JSONDecoder().decode(Music.self, from: data)
                } else {
                    throw RxCocoaURLError.httpRequestFailed(response: response, data: data)
                }
            }
    }
}
