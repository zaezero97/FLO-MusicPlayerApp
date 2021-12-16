//
//  MusicViewModel.swift
//  FLO-MusicPlayerApp
//
//  Created by 재영신 on 2021/12/16.
//

import Foundation
import RxSwift
import RxCocoa

class MusicViewModel {
    
    let musicSubject = BehaviorRelay<[Music]>(value: [])
    
    var title: Observable<String> {
        return self.musicSubject
            .map { $0.last!.title }
            .asObservable()
    }

    var singer: Observable<String> {
        return musicSubject.asObservable()
            .map{ $0.last!.singer }
    }
    
    var image: Observable<UIImage?> {
        return musicSubject.asObservable()
            .flatMap { music -> Observable<(response: HTTPURLResponse, data: Data)> in
                let url = URL(string: music.last!.image)
                if url == nil {
                    throw RxCocoaURLError.unknown
                }
                let request = URLRequest(url: url!)
                return URLSession.shared.rx.response(request: request)
            }.map { response,data -> UIImage? in
                if 200 ..< 300 ~= response.statusCode {
                    return UIImage(data: data)
                } else {
                    throw RxCocoaURLError.httpRequestFailed(response: response, data: data)
                }
            }
    }
    
    var file: Observable<Data> {
        return musicSubject.asObservable()
            .flatMap { music -> Observable<(response: HTTPURLResponse, data: Data)> in
                let url = URL(string: music.last!.image)
                if url == nil {
                    throw RxCocoaURLError.unknown
                }
                let request = URLRequest(url: url!)
                return URLSession.shared.rx.response(request: request)
            }.map { response,data -> Data in
                if 200 ..< 300 ~= response.statusCode {
                    return data
                } else {
                    throw RxCocoaURLError.httpRequestFailed(response: response, data: data)
                }
            }
    }
    
    var duration: Observable<Int> {
        return musicSubject.asObservable()
            .map { $0.last!.duration }
    }
    
    var lyrics: Observable<String> {
        return musicSubject.asObservable()
            .map { $0.last!.lyrics}
    }

   
}
