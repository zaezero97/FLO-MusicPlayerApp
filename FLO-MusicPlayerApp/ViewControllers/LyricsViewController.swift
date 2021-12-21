//
//  LyricsViewController.swift
//  FLO-MusicPlayerApp
//
//  Created by 재영신 on 2021/12/20.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import AVKit

class LyricsViewController: UIViewController {
    
    @IBOutlet weak var lyricToggleButton: UISwitch!
    @IBOutlet weak var lyricsTableView: UITableView!
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    var audioPlayer: AVAudioPlayer?
    var lyrics =  [(time: String, lyric: String)]()
    let disposeBag = DisposeBag()
    var musicViewModel: MusicViewModel?
    var timer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if audioPlayer != nil, audioPlayer!.isPlaying {
            playButton.setImage(UIImage(named: "pause.png"), for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        } else {
            playButton.setImage(UIImage(named: "play.png"), for: .normal)
        }
        
        bindingUI()
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }
    private func bindingUI() {
        guard let musicViewModel = musicViewModel else {
            return
        }
        
        // input 💩!!!
        self.playButton.rx.tap
            .asDriver()
            .drive(onNext: {
                self.playMusic()
            }).disposed(by: disposeBag)
        
        self.lyricToggleButton.rx.isOn
            .asDriver()
            .drive(musicViewModel.input.toggleSwitch)
            .disposed(by: disposeBag)
        
        self.lyricsTableView.rx.itemSelected
            .do(onNext: {
                [weak self] _ in
                guard let audioPlayer = self?.audioPlayer else {
                    return
                }
                if !audioPlayer.isPlaying {
                    audioPlayer.play()
                }
            })
            .bind(to: musicViewModel.input.clickLyric)
            .disposed(by: disposeBag)
        
        // output 💩!!!
        
        musicViewModel.output.title
            .drive(self.titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        musicViewModel.output.singer
            .drive(self.singerLabel.rx.text)
            .disposed(by: disposeBag)
        
        musicViewModel.output.lyrics
            .do(onNext: {
                lyrics in
                self.lyrics = lyrics
            })
            .drive(lyricsTableView.rx.items(cellIdentifier: "LyricCell")){
                index,item,cell in
                cell.textLabel?.text = item.lyric
                cell.textLabel?.textColor = .gray
            }.disposed(by: disposeBag)
        
        musicViewModel.output.moveLine
            .drive(onNext: {
                [weak self] indexPath in
                guard let self = self else { return }
                self.lyricsTableView.deselectRow(at: indexPath, animated: true)
                
                self.lyricsTableView.visibleCells.forEach{
                    $0.textLabel?.textColor = .gray
                }
                self.lyricsTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                let time = Float((self.lyrics[indexPath.row].time.tolyricTime()))
                self.audioPlayer?.currentTime = TimeInterval(time)
            }, onCompleted: nil, onDisposed: nil)
        
        musicViewModel.output.dismiss
            .drive(onNext: {
                [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
        
        musicViewModel.output.nextLine
            .drive(onNext: {
                [weak self] in
                var indexPath = IndexPath(row: $0, section: 0)
                var cell = self?.lyricsTableView.cellForRow(at: indexPath)
                cell?.textLabel?.textColor = .black
                indexPath.row = indexPath.row - 1
                cell = self?.lyricsTableView.cellForRow(at:indexPath)
                cell?.textLabel?.textColor = .gray
            })
        
    }
  
    @objc private func updateTime() {
        guard let audioPlayer = audioPlayer else {
            return
        }
        self.musicViewModel!.input.updateTime.onNext(audioPlayer.currentTime)

    }
    @IBAction func clickDoneButton(_ sender: Any) {
        
        let naviVC = self.presentingViewController as! UINavigationController
        let presentingVC = naviVC.children.first as! MusicPlayViewController
        
        if presentingVC.audioPlayer == nil {
            presentingVC.audioPlayer = audioPlayer
        }
    
        self.dismiss(animated: true, completion: nil)
    }
    
    private func playMusic() {
        guard let audioPlayer = audioPlayer else {
            return
        }
        if !audioPlayer.isPlaying {
            audioPlayer.play()
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            self.playButton.setImage(UIImage(named: "pause.png"), for: .normal)
        } else {
            audioPlayer.pause()
            timer?.invalidate()
            self.playButton.setImage(UIImage(named: "play.png"), for: .normal)
        }
        
        
    }
}
