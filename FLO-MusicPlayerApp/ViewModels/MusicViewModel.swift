//
//  MusicViewModel.swift
//  FLO-MusicPlayerApp
//
//  Created by 재영신 on 2021/12/16.
//

import Foundation
import RxSwift
import RxCocoa

protocol MusicViewModelType {
    
    associatedtype Input
    associatedtype Output
    
    var input: Input { get }
    var output: Output { get }
    var disposeBag: DisposeBag { get set }
    
}

class MusicViewModel: MusicViewModelType {

    struct Input {
        let fetchMusic: AnyObserver<Void>
    }
    
    struct Output {
        let title: Driver<String>
        let singer: Driver<String>
        let lyrics: Driver<String>
        let image: Driver<UIImage?>
        let file: Driver<Data?>
        let duration: Driver<Int>
    }
    
    let input: Input
    let output: Output
    var disposeBag = DisposeBag()
    
    var music = PublishRelay<Music>()
    
    init() {
        
        let fetchMusic = PublishSubject<Void>()
        
        
        let title = music.map{ $0.title }
        let singer = music.map { $0.singer }
        let lyrics = music.map { $0.lyrics }
        let image = music.map { try! Data(contentsOf: URL(string: $0.image)!) }.map{ UIImage(data: $0)}
        let file = music.map { try? Data(contentsOf: URL(string: $0.file)!) }
        let duration = music.map{ $0.duration }
        
        self.output = Output(title: title.asDriver(onErrorJustReturn: ""), singer: singer.asDriver(onErrorJustReturn: ""), lyrics: lyrics.asDriver(onErrorJustReturn: ""), image: image.asDriver(onErrorJustReturn: UIImage()), file: file.asDriver(onErrorJustReturn: Data()), duration: duration.asDriver(onErrorJustReturn: 0))
        self.input = Input(fetchMusic: fetchMusic.asObserver())
        
        
        // input
        fetchMusic.subscribe(onNext: {
            FLOAPIService.fetchMusic(URL(string: "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json")!).subscribe(onNext: {
                 [weak self] music in
                self?.music.accept(music)
            })
        })
        
        
        
        
        
        
    }
}
