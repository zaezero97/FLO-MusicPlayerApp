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
    
    @IBOutlet weak var lyricsTableView: UITableView!
  
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    var audioPlayer: AVAudioPlayer?
    var lyrics: [(time: String, lyric: String)]?
    let disposeBag = DisposeBag()
    var musicViewModel: MusicViewModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        binding()
    }
    private func binding() {
        guard let musicViewModel = musicViewModel else {
            return
        }
        
        musicViewModel.output.title
            .drive(self.titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        musicViewModel.output.singer
            .drive(self.singerLabel.rx.text)
            .disposed(by: disposeBag)
        
        musicViewModel.output.lyrics
            .drive(lyricsTableView.rx.items(cellIdentifier: "LyricCell")){
                index,item,cell in
                cell.textLabel?.text = item.lyric
                cell.textLabel?.textColor = .gray
            }.disposed(by: disposeBag)
        
       
    }
  
    @IBAction func clickDoneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func clickPlayButton(_ sender: Any) {
      
       
    }
}
