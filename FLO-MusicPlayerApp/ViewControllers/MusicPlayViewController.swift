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
    @IBOutlet weak var progressView: UIProgressView! {
        didSet {
            progressView.progress = 0
        }
    }
    @IBOutlet weak var lyricsTableView: UITableView! {
        didSet {
            lyricsTableView.isScrollEnabled = false
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clicklyricsTableView))
            lyricsTableView.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var musicImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton! {
        didSet {
            self.playButton.setImage(UIImage(named: "play.png"), for: .normal)
            playButton.isEnabled = false
        }
    }
    var audioPlayer: AVAudioPlayer?
    var timer: Timer!
    var musicViewModel = MusicViewModel()
    var lyrics = [(time:String, lyric: String)]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindingUI()
    }
    
    
    private func bindingUI() {
        
        // input 💩!!!
        
        self.musicViewModel.input.fetchMusic
            .onNext(Void())
        
        self.playButton.rx.tap
            .asDriver()
            .drive(onNext: {
                self.playMusic()
            })
            .disposed(by: disposeBag)
        
        
        // output 💩!!!
        
        self.musicViewModel.output.title
            .drive(self.titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        self.musicViewModel.output.singer
            .drive(self.singerLabel.rx.text)
            .disposed(by: disposeBag)
        
        self.musicViewModel.output.lyrics
            .drive(self.lyricsTableView.rx.items(cellIdentifier: "lyricCell")) {
                index,item,cell in
                cell.textLabel?.text = item.lyric
                cell.textLabel?.textColor = .gray
                print("item!!! ->>",item)
                self.lyrics.append(item)
            }.disposed(by: disposeBag)
        
        self.musicViewModel.output.image
            .drive(self.musicImageView.rx.image)
            .disposed(by: disposeBag)
        
        self.musicViewModel.output.duration
            .drive(self.endTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        self.musicViewModel.output.file
            .drive(onNext: { [weak self] data in
                guard let data = data else { return }
                self?.audioPlayer = try? AVAudioPlayer(data: data)
                self?.audioPlayer?.prepareToPlay()
                self?.playButton.isEnabled = true
            }, onCompleted: nil, onDisposed: nil)   
        
    }
    
    
    private func playMusic() {
        guard let audioPlayer = audioPlayer else {
            return
        }
        if !audioPlayer.isPlaying {
            audioPlayer.play()
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateCurTimeLabel), userInfo: nil, repeats: true)
            self.playButton.setImage(UIImage(named: "pause.png"), for: .normal)
        } else {
            audioPlayer.pause()
            timer.invalidate()
            self.playButton.setImage(UIImage(named: "play.png"), for: .normal)
        }
        
    }
    
    @objc private func updateCurTimeLabel() {
        
       
        guard let audioPlayer = audioPlayer else {
            return
        }
        
        let currentTime = round(audioPlayer.currentTime*10)/10
        self.curTimeLabel.text = Int(audioPlayer.currentTime).toMusicString()
        self.progressView.progress = Float(audioPlayer.currentTime / audioPlayer.duration)
        
        let index = lyrics.lastIndex { $0.time.tolyricTime() <= currentTime }
        
        if index != nil {
            self.lyricsTableView.scrollToRow(at: IndexPath(row: Int(index!), section: 0), at: .top, animated: true)
            let cell = self.lyricsTableView.cellForRow(at: IndexPath(row: Int(index!), section: 0))
            cell?.textLabel?.textColor = .black
        }
    }
    
    @objc private func clicklyricsTableView() {
        let storyboard = UIStoryboard(name: "LyricsViewController", bundle: nil)
        let lyricsVC = storyboard.instantiateViewController(withIdentifier: "LyricsViewController") as! LyricsViewController
        lyricsVC.audioPlayer = audioPlayer
        lyricsVC.lyrics = lyrics
        lyricsVC.musicViewModel = musicViewModel
        lyricsVC.modalPresentationStyle = .fullScreen
        self.present(lyricsVC, animated: true, completion: nil)
    }
    
}



