/// Copyright (c) 2022 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import CameraManager
import Foundation
import UIKit

class RecorderViewController: UIViewController {
  let cameraManager = CameraManager()
  private let editor = VideoEditor()
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var cam: UIView!
  
  @IBOutlet weak var timeLabel: UILabel!
  var timer: Timer?
  var counter: Int = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCameraManager()
 
  }
  
  @objc func updateCounter() {
    self.counter += 1
    self.timeLabel.text = "\(self.counter)s"
  }
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    cameraManager.stopCaptureSession()
  }
  
  @IBAction func stop(_ sender: Any) {
    if !cameraManager.isRecording {
      return
    }
    counter = 0
    timer?.invalidate()
    timer = nil
    activityIndicator.startAnimating()
    cameraManager.stopVideoRecording { videoURL, _ in
      guard let videoURL = videoURL else {
        return
      }
      self.editor.makeBirthdayCard(fromVideoAt: videoURL, forName: "👍") { exportedURL in
        guard let exportedURL = exportedURL else {
          return
        }
        self.activityIndicator.stopAnimating()
        self.pickedURL = exportedURL
        self.performSegue(withIdentifier: "showVideo", sender: nil)
      }
    }
  }
  
  deinit {
    timer?.invalidate()
    timer = nil
  }
  
  @IBAction func start(_ sender: Any) {
    cameraManager.startRecordingVideo()
    if timer == nil {
       timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    cameraManager.cameraOutputMode = .videoOnly
    cameraManager.addPreviewLayerToView(cam)
    cameraManager.resumeCaptureSession()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  private var pickedURL: URL?
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard
      let url = pickedURL,
      let destination = segue.destination as? PlayerViewController
    else {
      return
    }
    
    destination.videoURL = url
  }
  
  fileprivate func setupCameraManager() {
    cameraManager.shouldEnableExposure = true
        
    cameraManager.writeFilesToPhoneLibrary = false
        
    cameraManager.shouldFlipFrontCameraImage = false
    cameraManager.showAccessPermissionPopupAutomatically = false
  }
}
