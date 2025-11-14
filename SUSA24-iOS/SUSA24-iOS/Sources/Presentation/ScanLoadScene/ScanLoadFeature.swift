//
//  ScanLoadFeature.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/9/25.
//

import Foundation

/// 문서 스캔 분석 Feature
///
/// BatchAddressAnalyzer를 사용하여 여러 이미지를 순차적으로 분석합니다.
struct ScanLoadFeature: DWReducer {
    // MARK: - Dependencies

    private let batchAnalyzer: BatchAddressAnalyzer

    init(batchAnalyzer: BatchAddressAnalyzer = BatchAddressAnalyzer()) {
        self.batchAnalyzer = batchAnalyzer
    }

    // MARK: - State

    struct State: DWState {
        /// 분석 중인지 여부
        var isScanning: Bool = false

        /// 현재 진행 중인 사진 인덱스 (1-based)
        var currentIndex: Int = 0

        /// 전체 사진 개수
        var totalCount: Int = 0

        /// 현재 사진 ID
        var currentPhotoId: UUID?

        /// 분석 완료된 주소 결과
        var scanResults: [ScanResult] = []

        /// 성공한 이미지 개수
        var successCount: Int = 0

        /// 실패한 이미지 개수
        var failedCount: Int = 0

        /// 에러 메시지
        var errorMessage: String?

        /// 분석 완료 여부
        var isCompleted: Bool {
            !isScanning && currentIndex == totalCount && totalCount > 0
        }

        /// 진행률 (0.0 ~ 1.0)
        var progress: Double {
            guard totalCount > 0 else { return 0 }
            return Double(currentIndex) / Double(totalCount)
        }

        /// 진행률 퍼센티지 (0 ~ 100)
        var progressPercentage: Int {
            Int(progress * 100)
        }
    }

    // MARK: - Action

    enum Action: DWAction {
        /// 스캔 시작
        case startScanning(photos: [CapturedPhoto])

        /// 진행 상태 업데이트
        case updateProgress(progress: BatchAddressAnalyzer.AnalysisProgress)

        /// 스캔 완료
        case scanningCompleted(result: BatchAddressAnalyzer.BatchAnalysisResult)

        /// 스캔 실패
        case scanningFailed(errorMessage: String)
    }

    // MARK: - Reducer

    func reduce(into state: inout State, action: Action) -> DWEffect<Action> {
        switch action {
        case let .startScanning(photos):
            state.isScanning = true
            state.currentIndex = 0
            state.totalCount = photos.count
            state.scanResults = []
            state.successCount = 0
            state.failedCount = 0
            state.errorMessage = nil

            return .task { [batchAnalyzer] in
                let result = await batchAnalyzer.analyzePhotos(photos, progressHandler: nil)
                return .scanningCompleted(result: result)
            }

        case let .updateProgress(progress):
            state.currentIndex = progress.currentIndex
            state.totalCount = progress.totalCount
            state.currentPhotoId = progress.currentPhoto.id
            return .none

        case let .scanningCompleted(result):
            state.isScanning = false
            state.currentIndex = result.totalCount
            state.successCount = result.successCount
            state.failedCount = result.failedCount

            // [String: Int] → [ScanResult] 변환
            state.scanResults = result.addresses
                .map { address, count in
                    ScanResult(
                        address: address,
                        duplicateCount: count,
                        sourcePhotoIds: []
                    )
                }
                .sorted { $0.duplicateCount > $1.duplicateCount }

            // 에러 처리
            if state.scanResults.isEmpty {
                state.errorMessage = "추출된 주소가 없습니다."
            } else if result.failedCount > 0 {
                state.errorMessage = "\(result.failedCount)개 이미지 분석 실패"
            }

            return .none

        case let .scanningFailed(errorMessage):
            state.isScanning = false
            state.errorMessage = errorMessage
            return .none
            //        case .retry:
            //            state.errorMessage = nil
            //            return .none
        }
    }
}
