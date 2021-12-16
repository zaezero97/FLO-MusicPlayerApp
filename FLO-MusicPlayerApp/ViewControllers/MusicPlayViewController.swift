//
//  MusicPlayViewController.swift
//  FLO-MusicPlayerApp
//
//  Created by 재영신 on 2021/12/16.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
class MusicPlayViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var curTimeLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var musicImageView: UIImageView!
    @IBOutlet weak var lyricsTextView: UITextView!
    let url = "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json"
    var musicViewModel = MusicViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchMusic()
    }
    
    private func fetchMusic() {
        
        guard let url = URL(string: url) else {
            print("url string Error 😹!!")
            return
        }
        
        URLRequest.load(url)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                music in
                
                var musics = self.musicViewModel.musicSubject.value
                musics.append(music)
                self.musicViewModel.musicSubject.accept(musics)
                self.bindingUI()
                print(music)
                
            })
            
    }
    
    private func bindingUI() {
        
        
        self.musicViewModel.title
            .asDriver(onErrorJustReturn: "unknown")
            .drive(self.titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        self.musicViewModel.singer
            .asDriver(onErrorJustReturn: "unknown")
            .drive(self.singerLabel.rx.text)
            .disposed(by: disposeBag)
        
        self.musicViewModel.image
            .asDriver(onErrorJustReturn: UIImage())
            .drive(self.musicImageView.rx.image)
            .disposed(by: disposeBag)
        
        self.musicViewModel.duration
            .map { "\($0/60):\($0%60)"}
            .asDriver(onErrorJustReturn: "00:00")
            .drive(self.endTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
    }
}
