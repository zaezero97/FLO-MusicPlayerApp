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
    
    @IBOutlet weak var progressSlider: UISlider!{
        didSet {
            progressSlider.value = 0
            
        }
    }
    @IBOutlet weak var lyricsTableView: UITableView! {
        didSet {
            lyricsTableView.isScrollEnabled = false
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
    var timer: Timer?
    var musicViewModel = MusicViewModel()
    var lyrics = [(time:String, lyric: String)]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindingUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let audioPlayer = audioPlayer else {
            return
        }
        
        if audioPlayer.isPlaying {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            self.playButton.setImage(UIImage(named: "pause.png"), for: .normal)
        } else {
            self.playButton.setImage(UIImage(named: "play.png"), for: .normal)
            timer?.invalidate()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }
    private func bindingUI() {
        
        // input 💩!!!
        
        self.musicViewModel.input.fetchMusic
            .onNext(Void())
        
        self.playButton.rx.tap
            .asDriver()
            .filter({ [weak self] _ in
                return self?.audioPlayer != nil
            })
            .drive(onNext: {
                self.playMusic()
            })
            .disposed(by: disposeBag)
        
        self.lyricsTableView.rx.itemSelected
            .bind(onNext: {
                [weak self] _ in
                self?.clicklyricsTableView()
            }).disposed(by: disposeBag)
        
        self.progressSlider.rx.value
            .bind { value in
                self.curTimeLabel.text = Int(value).toMusicString()
            }.disposed(by: disposeBag)
        
        // output 💩!!!
        
        self.musicViewModel.output.title
            .drive(self.titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        self.musicViewModel.output.singer
            .drive(self.singerLabel.rx.text)
            .disposed(by: disposeBag)
        
        self.musicViewModel.output.lyrics
            .do(onNext: {
                self.lyrics = $0
            })
            .drive(self.lyricsTableView.rx.items(cellIdentifier: "lyricCell")) {
                index,item,cell in
                cell.selectionStyle = .none
                cell.textLabel?.text = item.lyric
                cell.textLabel?.textColor = .gray
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
                self?.progressSlider.maximumValue = Float(self?.audioPlayer?.duration ?? 0)
                self?.audioPlayer?.prepareToPlay()
                self?.playButton.isEnabled = true
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        
        self.musicViewModel.output.curTime
            .drive(self.curTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        self.musicViewModel.output.progress
                .drive(self.progressSlider.rx.value)
                .disposed(by: disposeBag)
        
        self.musicViewModel.output.nextLine
            .drive(onNext: {
                [weak self] in
                var indexPath = IndexPath(row: $0, section: 0)
                self?.lyricsTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                var cell = self?.lyricsTableView.cellForRow(at: indexPath)
                cell?.textLabel?.textColor = .black
               
            }).disposed(by: disposeBag)
                
                
    }
    
    private func playMusic() {
        guard let audioPlayer = audioPlayer else {
            return
        }
        if !audioPlayer.isPlaying {
            audioPlayer.play()
            audioPlayer.currentTime = TimeInterval(progressSlider.value)
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            self.playButton.setImage(UIImage(named: "pause.png"), for: .normal)
        } else {
            audioPlayer.pause()
            timer?.invalidate()
            self.playButton.setImage(UIImage(named: "play.png"), for: .normal)
        }
        
    }
    
    @objc private func updateTime() {
        
        guard let audioPlayer = audioPlayer else {
            return
        }
        self.musicViewModel.input.updateTime.onNext(audioPlayer.currentTime)
    }
    
    @objc private func clicklyricsTableView() {
        let storyboard = UIStoryboard(name: "LyricsViewController", bundle: nil)
        let lyricsVC = storyboard.instantiateViewController(withIdentifier: "LyricsViewController") as! LyricsViewController
        lyricsVC.audioPlayer = audioPlayer
        lyricsVC.musicViewModel = musicViewModel
        lyricsVC.modalPresentationStyle = .fullScreen
        self.present(lyricsVC, animated: true, completion: nil)
    }
    
  
}



