//
//  ViewController.swift
//  AKPlayerDemo
//
//  Created by Cary on 2020/11/20.
//

import UIKit
import Foundation
import AudioKit

class ViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    
    var player : AKPlayer!
    
    private lazy var audioPlayer: AWPCMPlayer = {
        let path: String = Bundle.main.path(forResource: "in", ofType: "pcm")!
        let player = AWPCMPlayer(file: path, rate: 44100, channel: 2, bit: 16)
        return player!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AKSettings.enableLogging = true
    }

    @IBAction func playButtonClicked(_ sender: Any) {
//        systemPlay()
//        basicPlay()
        useFormatPlay()
    }
    
    func systemPlay() {
        audioPlayer.start()
    }
    
    func basicPlay() {
        do {
            try AKSettings.setSession(category: .playback)
            let player = AKPlayer.init()
            player.completionHandler = { AKLog("Done") }
            let url = Bundle.main.url(forResource: "test", withExtension: "caf")!
            try player.load(url: url)
            
            // Loop Options
            player.loop.start = 1
            player.loop.end = 3
            player.isLooping = true
    //        player.buffer = true // if seamless is desired

            AKManager.output = player
            if !AKManager.engine.isRunning {
                try AKManager.start()
            }
            player.play()
        } catch {
            
        }
    }
    
    func useFormatPlay() {
        do {
            try AKSettings.setSession(category: .playback)
            player = AKPlayer.init()
            player.completionHandler = { AKLog("Done") }
            
            // Loop Options
            player.loop.start = 1
            player.loop.end = 3
            player.isLooping = true
            player.buffering = .always
            let url = Bundle.main.url(forResource: "in", withExtension: "pcm")!
            let data = try Data.init(contentsOf: url)
            let format = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 44100, channels: 2, interleaved: true)!
            // loaded into AVAudioPCMBuffer
            guard let buffer = data.convertedTo(format) else { return }
            player.buffer = buffer

            AKManager.output = player
            if !AKManager.engine.isRunning {
                try AKManager.start()
            }
            player.play()
        } catch {
            
        }
    }
}

