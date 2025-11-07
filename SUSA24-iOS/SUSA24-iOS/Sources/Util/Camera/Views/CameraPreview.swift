//
//  CameraPreview.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/5/25.
//

@preconcurrency import AVFoundation
import SwiftUI

/// 카메라 캡처 내용을 표시하는 뷰
struct CameraPreview: UIViewRepresentable {
    private let source: PreviewSource
    
    init(source: PreviewSource) {
        self.source = source
    }
    
    func makeUIView(context _: Context) -> PreviewView {
        let preview = PreviewView()
        // 프리뷰 레이어와 캡처 세션을 연결합니다.
        source.connect(to: preview)
        return preview
    }
    
    func updateUIView(_: PreviewView, context _: Context) {
        // No-op
    }
    
    /// 캡처된 내용을 표시하는 클래스
    /// AVCaptureVideoPreviewLayer를 소유하고 캡처된 내용을 표시합니다.
    class PreviewView: UIView, PreviewTarget {
        init() {
            super.init(frame: .zero)
            #if targetEnvironment(simulator)
                // 캡처 API는 실제 디바이스에서만 작동합니다.
                // 시뮬레이터에서는 정적 이미지를 표시합니다.
                let imageView = UIImageView(frame: UIScreen.main.bounds)
                imageView.image = UIImage(named: "video_mode")
                imageView.contentMode = .scaleAspectFill
                imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                addSubview(imageView)
            #endif
        }
        
        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // 프리뷰 레이어를 뷰의 backing 레이어로 사용합니다.
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var previewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }
        
        nonisolated func setSession(_ session: AVCaptureSession) {
            // 세션과 프리뷰 레이어를 연결하여
            // 레이어가 캡처된 내용의 라이브 뷰를 제공하도록 합니다.
            Task { @MainActor in
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
            }
        }
    }
}

/// 프리뷰 소스가 프리뷰 타겟과 연결되도록 하는 프로토콜
/// 앱은 이 타입의 인스턴스를 제공하여 캡처 세션을
/// PreviewView와 연결합니다. 캡처 객체를 UI 레이어에
/// 명시적으로 노출하지 않기 위해 프로토콜을 사용합니다.
protocol PreviewSource: Sendable {
    /// 프리뷰 대상을 이 소스에 연결합니다.
    func connect(to target: PreviewTarget)
}

/// 앱의 캡처 세션을 CameraPreview 뷰에 전달하는 프로토콜
protocol PreviewTarget {
    /// 대상에서 캡처 세션을 설정합니다.
    func setSession(_ session: AVCaptureSession)
}

/// PreviewSource의 기본 구현
struct DefaultPreviewSource: PreviewSource {
    private let session: AVCaptureSession
    
    init(session: AVCaptureSession) {
        self.session = session
    }
    
    func connect(to target: PreviewTarget) {
        target.setSession(session)
    }
}
