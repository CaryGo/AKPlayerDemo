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
            AKSettings.sampleRate = 44100
            AKSettings.channelCount = 2
            AKSettings.playbackWhileMuted = true
            AKSettings.enableRouteChangeHandling = true
            AKSettings.useBluetooth = true
            AKSettings.allowAirPlay = true
            AKSettings.defaultToSpeaker = true
            AKSettings.audioInputEnabled = true
            
            player = AKPlayer.init()
            player.completionHandler = { AKLog("Done") }
            
            // Loop Options
            player.loop.start = 1
            player.loop.end = 3
            player.isLooping = true
            player.buffering = .always
            
//            var options = AKConverter.Options()
//            // any options left nil will assume the value of the input file
//            options.format = "wav"
//            options.sampleRate = 44100
//            options.bitDepth = 16
//            options.channels = 2
//
//            let oldURL = Bundle.main.url(forResource: "in", withExtension: "pcm")!
//            let newURL = self.urlForDocument("in.wav")!
//            let converter = AKConverter(inputURL: oldURL, outputURL: newURL, options: options)
//            converter.start(completionHandler: { error in
//            // check to see if error isn't nil, otherwise you're good
//            })
            
//            let format = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 44100, channels: 2, interleaved: true)!
            let url = Bundle.main.url(forResource: "in", withExtension: "pcm")!
            let audioFile = try AVAudioFile.init(forReading: url)
            try player.load(audioFile: audioFile)

            AKManager.output = player
            if !AKManager.engine.isRunning {
                try AKManager.start()
            }
            player.play()
        } catch {
            print("AKPlayer did not start")
        }
    }
    
    func urlForDocument(_ named:String) -> URL? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(named) {
            return pathComponent
        }
        return nil
    }
}

