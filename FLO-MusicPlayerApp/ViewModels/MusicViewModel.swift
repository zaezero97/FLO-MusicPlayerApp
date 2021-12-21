//
//  MusicViewModel.swift
//  FLO-MusicPlayerApp
//
//  Created by 재영신 on 2021/12/16.
//

import Foundation
import RxSwift
import RxCocoa

enum PlayType: String{
    case play
    case pause
}


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
        let toggleSwitch: AnyObserver<Bool>
        let clickLyric: AnyObserver<IndexPath>
        let updateTime: AnyObserver<TimeInterval>
        
    }
    
    struct Output {
        let title: Driver<String>
        let singer: Driver<String>
        let lyrics: Driver<[(time: String, lyric: String)]>
        let image: Driver<UIImage?>
        let file: Driver<Data?>
        let duration: Driver<String>
        let moveLine: Driver<IndexPath>
        let dismiss: Driver<Void>
        let curTime: Driver<String>
        let progress: Driver<Float>
        let nextLine: Driver<Int>
        
    }
    
    let input: Input
    let output: Output
    var disposeBag = DisposeBag()
    
    var music = PublishRelay<Music>()
    
    init() {
        
        // input 💩!!!
        let fetchMusic = PublishSubject<Void>()
        let toggleSwitch = BehaviorSubject<Bool>(value: true)
        let clickLyric = PublishSubject<IndexPath>()
        let updateTime = PublishSubject<TimeInterval>()
        
        // output 💩!!!
        let title = music.map{ $0.title }
        let singer = music.map{ $0.singer }
        let lyrics = music.map{ $0.lyrics }.map{ $0.split(separator: "\n").map{
            (splitedLyric) -> (time:String, lyric: String) in
            let str = String(splitedLyric)
            let splitIndex = str.index(str.startIndex, offsetBy: 10)
            return (time: String(str[str.startIndex...splitIndex]), lyric: String(str[str.index(splitIndex, offsetBy: 1)...]))
        }}
        
        let image = music.map { try! Data(contentsOf: URL(string: $0.image)!) }.map{ UIImage(data: $0)}
        let file = music.map { try? Data(contentsOf: URL(string: $0.file)!) }
        let duration = music.map{ $0.duration }.map{ $0.toMusicString() }
        
        let moveLine = Observable.combineLatest(toggleSwitch, clickLyric).filter{
            isOn, _ in
            return isOn == true
        }.map{$0.1}
        
        
        let dismiss = Observable.combineLatest(toggleSwitch, clickLyric).filter{
            isOn, _ in
            return isOn == false
        }.map{ _ -> () in  }
        
        
        let curTime = updateTime.map{ Int($0).toMusicString() }
        let progress = updateTime.map { Float($0) }
        
        let nextLine = Observable.combineLatest(updateTime, lyrics)
            .map { timeinterval, lyrics -> Int in
                let currentTime = round(timeinterval*10)/10
                let index = lyrics.lastIndex {  $0.time.tolyricTime() <= currentTime }
                return index ?? -1
            }.skip(while: { $0 == -1 })
            .distinctUntilChanged()
        
       
        
        self.output = Output(title: title.asDriver(onErrorJustReturn: ""), singer: singer.asDriver(onErrorJustReturn: ""), lyrics: lyrics.asDriver(onErrorJustReturn: []), image: image.asDriver(onErrorJustReturn: UIImage()), file: file.asDriver(onErrorJustReturn: Data()), duration: duration.asDriver(onErrorJustReturn: "00:00"),moveLine: moveLine.asDriver(onErrorJustReturn: IndexPath(row: 0, section: 0)),dismiss: dismiss.asDriver(onErrorJustReturn: ()),curTime: curTime.asDriver(onErrorJustReturn: "00:00"), progress: progress.asDriver(onErrorJustReturn: 0), nextLine: nextLine.asDriver(onErrorJustReturn: 0))
        
        self.input = Input(fetchMusic: fetchMusic.asObserver(),toggleSwitch: toggleSwitch.asObserver(), clickLyric: clickLyric.asObserver(), updateTime: updateTime.asObserver())
        
        
        fetchMusic.subscribe(onNext: {
            FLOAPIService.fetchMusic(URL(string: "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json")!).subscribe(onNext: {
                [weak self] music in
                self?.music.accept(music)
            })
        }, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        
        
        
        
    }
}
