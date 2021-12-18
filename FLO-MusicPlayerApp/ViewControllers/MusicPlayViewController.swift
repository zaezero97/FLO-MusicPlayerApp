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
import AVFoundation


class MusicPlayViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var curTimeLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var musicImageView: UIImageView!
    @IBOutlet weak var lyricsTextView: UITextView!
    var audioPlayer: AVAudioPlayer!
    
    var musicViewModel = MusicViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindingUI()
    }
    
    
    private func bindingUI() {
        
        // input 💩!!!
        self.musicViewModel.input.fetchMusic
            .onNext(Void())
        
        // output 💩!!!
        
        self.musicViewModel.output.title
            .drive(self.titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        
        self.musicViewModel.output.singer
            .drive(self.singerLabel.rx.text)
            .disposed(by: disposeBag)
        
        self.musicViewModel.output.lyrics
            .drive(self.lyricsTextView.rx.text)
            .disposed(by: disposeBag)
        
        
        self.musicViewModel.output.image
            .drive(self.musicImageView.rx.image)
            .disposed(by: disposeBag)
        
    
//        self.musicViewModel.title
//            .asDriver(onErrorJustReturn: "unknown")
//            .drive(self.titleLabel.rx.text)
//            .disposed(by: disposeBag)
//
//        self.musicViewModel.singer
//            .asDriver(onErrorJustReturn: "unknown")
//            .drive(self.singerLabel.rx.text)
//            .disposed(by: disposeBag)
//
//        self.musicViewModel.image
//            .asDriver(onErrorJustReturn: UIImage())
//            .drive(self.musicImageView.rx.image)
//            .disposed(by: disposeBag)
//
//        self.musicViewModel.duration
//            .map { "\($0/60):\($0%60)"}
//            .asDriver(onErrorJustReturn: "00:00")
//            .drive(self.endTimeLabel.rx.text)
//            .disposed(by: disposeBag)
//
//        self.musicViewModel.file
//            .asDriver(onErrorJustReturn: Data())
//            .drive(onNext: {
//                data in
//                self.playMusic(data)
//            },onCompleted: nil,onDisposed: nil)
    }
    
    private func playMusic(_ data: Data) {
        do {
            self.audioPlayer = try AVAudioPlayer(data: data)
        } catch let error as NSError {
            print("Audio Player Create Error 👻 ->>", error.localizedDescription)
        }
        audioPlayer.play()
    }
}
