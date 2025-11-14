//
//  DocumentDetectionOverlayView.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/6/25.
//

import SwiftUI
import UIKit

/// 문서 감지 결과를 화면에 표시하는 오버레이 뷰
/// - 파란색 테두리: CAShapeLayer로 그린 사각형
/// - 반투명 오버레이: UIView의 backgroundColor
struct DocumentDetectionOverlayView: UIViewRepresentable {
    let documentDetection: DocumentDetectionResult?
    let screenSize: CGSize

    func makeUIView(context _: Context) -> OverlayUIView {
        let view = OverlayUIView()
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: OverlayUIView, context _: Context) {
        if let detection = documentDetection {
            uiView.updateDetection(detection, screenSize: screenSize)
        } else {
            uiView.clearDetection()
        }
    }
}

// MARK: - OverlayUIView

/// CAShapeLayer를 사용하여 문서 사각형을 그리는 뷰 (perspective 유지)
class OverlayUIView: UIView {
    private let shapeLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    private func setupLayers() {
        // CAShapeLayer로 문서 경계와 반투명 배경을 함께 그리기 (perspective 유지)
        shapeLayer.fillColor = UIColor(Color.primaryNormal.opacity(0.15)).cgColor // 반투명 파란색 배경
        shapeLayer.strokeColor = UIColor.primaryNormal.cgColor
        shapeLayer.lineWidth = 3
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        layer.addSublayer(shapeLayer)
    }

    /// 문서 감지 결과로 오버레이를 업데이트합니다
    func updateDetection(_ detection: DocumentDetectionResult, screenSize: CGSize) {
        // Vision 좌표 (정규화, 좌하단 원점) → 화면 좌표 (좌상단 원점)
        let screenCorners = detection.toScreenCoordinates(screenSize: screenSize)

        guard screenCorners.count == 4 else {
            clearDetection()
            return
        }

        // Perspective가 있는 사각형 경로 생성 (4개 꼭짓점 연결)
        // 메모 앱처럼 사각형이 아닌 사다리꼴 등의 형태로 표시됨
        let path = UIBezierPath()
        path.move(to: screenCorners[0]) // 좌상
        path.addLine(to: screenCorners[1]) // 우상
        path.addLine(to: screenCorners[2]) // 우하
        path.addLine(to: screenCorners[3]) // 좌하
        path.close() // 좌상으로 다시 연결

        // CAShapeLayer 업데이트 (배경 + 테두리 모두 처리)
        CATransaction.begin()
        CATransaction.setDisableActions(true) // 애니메이션 비활성화 (성능)
        shapeLayer.path = path.cgPath
        CATransaction.commit()
    }

    /// 오버레이를 지웁니다
    func clearDetection() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        shapeLayer.path = nil
        CATransaction.commit()
    }
}

// MARK: - Helper Extensions

extension [CGPoint] {
    /// 포인트 배열의 경계 상자를 계산합니다
    func boundingBox() -> CGRect {
        guard !isEmpty else { return .zero }

        let xs = map(\.x)
        let ys = map(\.y)

        let minX = xs.min() ?? 0
        let maxX = xs.max() ?? 0
        let minY = ys.min() ?? 0
        let maxY = ys.max() ?? 0

        return CGRect(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY
        )
    }
}

// MARK: - Preview

#if DEBUG
    struct DocumentDetectionOverlayView_Previews: PreviewProvider {
        static var previews: some View {
            let sampleDetection = DocumentDetectionResult(
                boundingBox: CGRect(x: 0.1, y: 0.2, width: 0.8, height: 0.6),
                corners: [
                    CGPoint(x: 0.1, y: 0.2),
                    CGPoint(x: 0.9, y: 0.25),
                    CGPoint(x: 0.85, y: 0.8),
                    CGPoint(x: 0.15, y: 0.75),
                ],
                confidence: 0.95,
                timestamp: 0
            )

            DocumentDetectionOverlayView(
                documentDetection: sampleDetection,
                screenSize: CGSize(width: 375, height: 812)
            )
            .frame(width: 375, height: 812)
            .background(Color.black)
        }
    }
#endif
