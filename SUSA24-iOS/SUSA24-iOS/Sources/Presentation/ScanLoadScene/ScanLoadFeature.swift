//
//  ScanLoadFeature.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/9/25.
//

import Foundation

/// 문서 스캔 분석 Feature
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

        /// 분석 완료된 주소 결과 (좌표 검증 완료)
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

        /// Vision 분석 완료 (아직 geocode 검증 전)
        case visionAnalysisCompleted(addresses: [String: Int], successCount: Int, failedCount: Int)
        
        /// Geocode 검증 완료 (최종 결과)
        case geocodeValidationCompleted(scanResults: [ScanResult], failedAddressCount: Int)

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
                // 1단계: Vision 분석
                let result = await batchAnalyzer.analyzePhotos(photos, progressHandler: nil)
                return .visionAnalysisCompleted(
                    addresses: result.addresses,
                    successCount: result.successCount,
                    failedCount: result.failedCount
                )
            }

        case let .updateProgress(progress):
            state.currentIndex = progress.currentIndex
            state.totalCount = progress.totalCount
            state.currentPhotoId = progress.currentPhoto.id
            return .none

        case let .visionAnalysisCompleted(addresses, successCount, failedCount):
            // Vision 분석 결과 저장
            state.successCount = successCount
            state.failedCount = failedCount
            
            // 2단계: Geocode 검증 시작
            return .task {
                await validateAddressesWithGeocode(addresses: addresses)
            }
            
        case let .geocodeValidationCompleted(scanResults, _):
            // 최종 결과 저장
            state.isScanning = false
            state.scanResults = scanResults.sorted { $0.duplicateCount > $1.duplicateCount }
            state.currentIndex = state.totalCount
            
            // TODO: 실패한 주소 개수 출력 (추후 고도화용)
//            print("[ScanLoad] Geocode 검증 완료")
//            print("   성공: \(scanResults.count)개")
//            print("   실패: \(failedAddressCount)개 (좌표 검증 실패)")
            
            // 에러 처리
            if state.scanResults.isEmpty {
                state.errorMessage = "좌표 검증에 성공한 주소가 없습니다."
            }

            return .none

        case let .scanningFailed(errorMessage):
            state.isScanning = false
            state.errorMessage = errorMessage
            return .none
        }
    }
    
    // MARK: - Private Methods
    
    /// 주소 목록을 Geocode API로 검증하여 좌표를 가져옵니다.
    /// - Parameter addresses: 중복 제거된 주소 목록 [주소: 중복횟수]
    /// - Returns: 검증된 ScanResult 배열과 실패 개수
    private func validateAddressesWithGeocode(addresses: [String: Int]) async -> Action {
        // 중복 제거된 주소 리스트
        let uniqueAddresses = Array(addresses.keys)
        
        // 병렬 처리로 각 주소 검증
        let results = await withTaskGroup(of: (String, Int, Address?)?.self) { group in
            for address in uniqueAddresses {
                let duplicateCount = addresses[address] ?? 1
                
                group.addTask {
                    do {
                        let geocode = try await NaverGeocodeAPIService.shared.geocode(address: address)
                        return (address, duplicateCount, geocode)
                    } catch {
                        // 실패한 주소는 nil 반환
                        return nil
                    }
                }
            }
            
            // 결과 수집
            var validResults: [(String, Int, Address)] = []
            for await result in group {
                if let result {
                    validResults.append((result.0, result.1, result.2!))
                }
            }
            return validResults
        }
        
        // ScanResult로 변환 (좌표 검증 성공한 것만)
        let scanResults = results.compactMap { _, duplicateCount, geocode -> ScanResult? in
            guard let latitude = geocode.latitude,
                  let longitude = geocode.longitude
            else {
                return nil
            }
            
            return ScanResult(
                roadAddress: geocode.roadAddress, // 신주소
                jibunAddress: geocode.jibunAddress, // 구주소
                duplicateCount: duplicateCount,
                sourcePhotoIds: [],
                latitude: latitude,
                longitude: longitude
            )
        }
        
        let failedCount = uniqueAddresses.count - results.count
        
        return .geocodeValidationCompleted(
            scanResults: scanResults,
            failedAddressCount: failedCount
        )
    }
}
