//
//  ViewController.swift
//  DataWriting-Example
//
//  Created by cleanmac on 06/11/23.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    private var currentPath: String = "data-example-\(UUID().uuidString).MP4"
    private var currentURL: URL {
        let cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        return cachePath!.appendingPathComponent(currentPath)
    }
    private var videoBundleURL: URL {
        Bundle.main.url(forResource: "data-example", withExtension: "MP4")!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfDataInStorageExists()
    }
    
    private func checkIfDataInStorageExists() {
        if FileManager.default.fileExists(atPath: currentURL.absoluteString) {
            do {
                try FileManager.default.removeItem(atPath: currentURL.absoluteString)
            } catch {
                print("Failed to remove data at: \(currentURL.absoluteString); with error \(error.localizedDescription)")
            }
        }
    }

    @IBAction func writeToStorageAction(_ sender: Any) {
        checkIfDataInStorageExists()
        
        if let videoData = try? Data(contentsOf: videoBundleURL) {
            let chunkedData = videoData.chunked()
            
            chunkedData.enumerated().forEach { index, data in
                if index == 0 {
                    FileManager.default.createFile(atPath: currentURL.path, contents: nil)
                    do {
                        try data.write(to: currentURL, options: .atomic)
                    } catch {
                        print("Failed to write data with error: \(error.localizedDescription)")
                    }
                } else {
                    if let fileHandle = try? FileHandle(forWritingTo: currentURL) {
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                        
                        if index == chunkedData.count - 1 {
                            fileHandle.closeFile()
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func playAction(_ sender: Any) {
        if FileManager.default.fileExists(atPath: currentURL.path) {
            print("File exist: \(currentURL.path)")
            
            let asset = AVAsset(url: currentURL)
            let player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
            let playerVC = AVPlayerViewController()
            playerVC.player = player
            present(playerVC, animated: true) {
                player.play()
            }
        } else {
            print("File not exist")
        }
    }
    
}

