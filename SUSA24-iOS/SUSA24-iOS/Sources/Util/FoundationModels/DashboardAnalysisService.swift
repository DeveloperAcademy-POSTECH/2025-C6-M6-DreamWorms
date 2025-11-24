//
//  DashboardAnalysisService.swift
//  SUSA24-iOS
//
//  Created by mini on 11/16/25.
//

import Foundation
import FoundationModels

protocol DashboardAnalysisServiceProtocol: Sendable {
    /// 체류시간 탭 요약 스트리밍
    func streamVisitDurationAnalysis(
        locations: [Location],
        topDuration: [StayAddress]
    ) -> AsyncThrowingStream<VisitDurationSummary.PartiallyGenerated, Error>
    
    /// 방문빈도 탭 요약 스트리밍
    func streamVisitFrequencyAnalysis(
        locations: [Location],
        topFrequency: [StayAddress]
    ) -> AsyncThrowingStream<VisitFrequencySummary.PartiallyGenerated, Error>
}

actor DashboardAnalysisService: DashboardAnalysisServiceProtocol {
    private let session: LanguageModelSession

    init() {
        self.session = LanguageModelSession(
            tools: [],
            instructions: Instructions {
                """
                너는 '기지국 대시보드' 상단에 들어갈 짧은 분석 문장을 만들어 주는 도우미야.
                
                - VisitDurationSummary.title: 체류시간 1위 지역에 대한 3줄짜리 문장
                - VisitFrequencySummary.title: 방문빈도 1위 지역에 대한 3줄짜리 문장
                """
            }
        )
    }
    
    nonisolated func streamVisitDurationAnalysis(
        locations: [Location],
        topDuration: [StayAddress]
    ) -> AsyncThrowingStream<VisitDurationSummary.PartiallyGenerated, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let durationTop = topDuration.first
                    let durationAddress = durationTop?.address ?? "해당 지역"
                    
                    let timeRangeString = mostLikelyTimeRangeString(
                        for: durationAddress,
                        locations: locations
                    )
                    
                    let stream = self.session.streamResponse(
                        generating: VisitDurationSummary.self,
                        includeSchemaInPrompt: false,
                        options: GenerationOptions(sampling: .greedy)
                    ) {
                        durationPrompt(
                            durationAddress: durationAddress,
                            timeRangeString: timeRangeString
                        )
                    }
                    
                    for try await partial in stream {
                        continuation.yield(partial.content)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
        
    nonisolated func streamVisitFrequencyAnalysis(
        locations: [Location],
        topFrequency: [StayAddress]
    ) -> AsyncThrowingStream<VisitFrequencySummary.PartiallyGenerated, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let frequencyTop = topFrequency.first
                    let frequencyAddress = frequencyTop?.address ?? "해당 지역"
                    
                    let (bestDateString, bestWeekdayString) = mostVisitedDateString(
                        for: frequencyAddress,
                        locations: locations
                    )
                    
                    let stream = self.session.streamResponse(
                        generating: VisitFrequencySummary.self,
                        includeSchemaInPrompt: false,
                        options: GenerationOptions(sampling: .greedy)
                    ) {
                        frequencyPrompt(
                            frequencyAddress: frequencyAddress,
                            bestDateString: bestDateString,
                            bestWeekdayString: bestWeekdayString
                        )
                    }
                    
                    for try await partial in stream {
                        continuation.yield(partial.content)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

nonisolated extension DashboardAnalysisService {
    func durationPrompt(
        durationAddress: String,
        timeRangeString: String
    ) -> String {
        """
        아래는 기지국 체류시간 분석 결과야.
        
        [체류시간 기준 1위 지역]
        - 주소: \(durationAddress)
        - 가장 머무를 가능성이 높은 시간대: \(timeRangeString)
        
        위 정보를 사용해서, VisitDurationSummary.title 필드를 채울 문자열을 만들어줘.
        
        VisitDurationSummary.title 은 **항상 정확히 3줄**로 작성해.
        - 1줄: "체류시간 1위 지역에서"
        - 2줄: 위에서 제공한 시간대 `\(timeRangeString)`을 그대로 사용한 문장
        - 3줄: "머무를 가능성이 가장 높아요." 와 비슷한 의미의 문장
        
        규칙:
        - 줄과 줄 사이는 **문자 `\\n` 한 개**로만 구분해.
        - 따라서 전체 문자열 안에는 **줄바꿈 문자(`\\n`)가 정확히 2개**만 있어야 해.
        - 각 줄의 앞뒤에는 공백을 넣지 마.
        
        예시:
        "체류시간 1위 지역에서\\n오전 11시-오후 12시에\\n머무를 가능성이 가장 높아요."
        """
    }
        
    func frequencyPrompt(
        frequencyAddress: String,
        bestDateString: String,
        bestWeekdayString: String
    ) -> String {
        """
        아래는 기지국 방문 빈도 분석 결과야.
        
        [방문빈도 기준 1위 지역]
        - 주소: \(frequencyAddress)
        - 가장 많이 방문한 날짜: \(bestDateString) (\(bestWeekdayString))
        
        위 정보를 사용해서, VisitFrequencySummary.title 필드를 채울 문자열을 만들어줘.
        
        VisitFrequencySummary.title 은 **항상 정확히 3줄**로 작성해.
        - 1줄: "방문빈도 1위 지역은"
        - 2줄: 제공된 날짜와 요일 `\(bestDateString) \(bestWeekdayString)`을 그대로 사용한 문장
        - 3줄: "가장 많이 방문했어요." 와 비슷한 의미의 문장
        
        규칙:
        - 줄과 줄 사이는 **문자 `\\n` 한 개**로만 구분해.
        - 따라서 전체 문자열 안에는 **줄바꿈 문자(`\\n`)가 정확히 2개**만 있어야 해.
        - 각 줄의 앞뒤에는 공백을 넣지 마.
        
        예시:
        "방문빈도 1위 지역은\\n10월 27일 수요일에\\n가장 많이 방문했어요."
        """
    }
    
    /// 특정 주소에 대해 가장 많이 방문한 날짜와 요일을 계산합니다.
    func mostVisitedDateString(
        for address: String,
        locations: [Location]
    ) -> (dateString: String, weekdayString: String) {
        let filtered = locations.filter {
            $0.locationType == 2 &&
                ($0.address.isEmpty ? "기지국 주소" : $0.address) == address
        }
        guard !filtered.isEmpty else {
            return ("날짜 정보 없음", "")
        }

        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filtered.compactMap(\.receivedAt)) { date in
            calendar.startOfDay(for: date)
        }

        guard let (bestDate, _) = grouped.max(by: { $0.value.count < $1.value.count }) else {
            return ("날짜 정보 없음", "")
        }

        let date = bestDate

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "M월 d일"

        let weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = Locale(identifier: "ko_KR")
        weekdayFormatter.dateFormat = "EEEE"

        let dateString = dateFormatter.string(from: date)
        let weekdayString = weekdayFormatter.string(from: date)
        return (dateString, weekdayString)
    }

    /// 특정 주소에 대해 가장 많이 머문 시간대를 `"오전 h시-오후 h시"` 형식으로 계산합니다.
    func mostLikelyTimeRangeString(
        for address: String,
        locations: [Location]
    ) -> String {
        let calendar = Calendar.current

        let filtered = locations.compactMap { location -> Date? in
            guard location.locationType == 2 else { return nil }
            let addr = location.address.isEmpty ? "기지국 주소" : location.address
            guard addr == address else { return nil }
            return location.receivedAt
        }

        guard !filtered.isEmpty else { return "시간 정보 없음" }

        var bucket: [Int: Int] = [:]
        for date in filtered {
            let hour = calendar.component(.hour, from: date)
            bucket[hour, default: 0] += 1
        }

        guard let (bestHour, _) = bucket.max(by: { $0.value < $1.value }) else {
            return "시간 정보 없음"
        }

        let startHour = bestHour
        let endHour = (bestHour + 1) % 24

        func hourText(_ h: Int) -> String {
            switch h {
            case 0: "오전 0시"
            case 1 ..< 12: "오전 \(h)시"
            case 12: "오후 12시"
            default: "오후 \(h - 12)시"
            }
        }

        return "\(hourText(startHour))-\(hourText(endHour))"
    }
}
