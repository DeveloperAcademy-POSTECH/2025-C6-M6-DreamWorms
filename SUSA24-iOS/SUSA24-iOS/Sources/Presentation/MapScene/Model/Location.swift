//
//  Location.swift
//  SUSA24-iOS
//
//  Created by Moo on 11/3/25.
//

/// 위치 정보 모델

import Foundation

// MARK: - Models

struct Location: Identifiable, Equatable, Sendable, Hashable {
    var id: UUID
    var address: String
    var title: String?
    var note: String?
    var pointLatitude: Double
    var pointLongitude: Double
    var boxMinLatitude: Double?
    var boxMinLongitude: Double?
    var boxMaxLatitude: Double?
    var boxMaxLongitude: Double?
    var locationType: Int16
    var colorType: Int16
    var receivedAt: Date?
}

// MARK: - Extensions Methods

extension Array<Location> {
    /// 체류 시간 기준으로 상위 N개의 기지국을 반환합니다.
    ///
    /// - Parameters:
    ///   - sampleIntervalMinutes: 한 샘플이 의미하는 시간(분 단위, 기본값 5분)
    ///   - maxCount: 상위 개수 (기본값 3개)
    /// - Returns: 체류 시간이 긴 순서의 `StayAddress` 배열
    func topVisitDuration(
        sampleIntervalMinutes: Int = 5,
        maxCount: Int = 3
    ) -> [StayAddress] {
        summarizedStays(sampleIntervalMinutes: sampleIntervalMinutes)
            .sorted { $0.totalMinutes > $1.totalMinutes }
            .prefix(maxCount)
            .map(\.self)
    }
    
    /// 방문 빈도 기준으로 상위 N개의 기지국을 반환합니다.
    ///
    /// 방문 빈도는 VisitFrequencyCalculator의 "연속 그룹" 방식을 사용합니다.
    ///
    /// - Parameters:
    ///   - sampleIntervalMinutes: 한 샘플이 의미하는 시간(분 단위, 기본값 5분)
    ///   - maxCount: 상위 개수 (기본값 3개)
    /// - Returns: 방문 빈도가 높은 순서의 `StayAddress` 배열
    func topVisitFrequency(
        sampleIntervalMinutes: Int = 5,
        maxCount: Int = 3
    ) -> [StayAddress] {
        summarizedStays(sampleIntervalMinutes: sampleIntervalMinutes)
            .sorted { $0.visitCount > $1.visitCount }
            .prefix(maxCount)
            .map(\.self)
    }
    
    /// 기지국 데이터에서 상위 몇 개 주소에 대해
    /// 시간대별 방문 패턴을 `CellChartData`로 생성합니다.
    ///
    /// - Parameters:
    ///   - maxAddressCount: 차트로 보여줄 상위 주소 개수 (기본값 3개)
    ///   - maxWeeks: 최대 고려 주차 수 (기본값 4주)
    /// - Returns: 주소별 시간대 방문 패턴을 담은 `CellChartData` 배열
    func buildCellChartData(
        maxAddressCount: Int = 3,
        maxWeeks: Int = 4
    ) -> [CellChartData] {
        let cellTowerLocations = filterCellTowerLocations()
        guard
            !cellTowerLocations.isEmpty,
            let dateRange = makeCellTowerDateRange(from: cellTowerLocations)
        else { return [] }
        
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // 월요일 시작
        
        let baseWeekStart = makeBaseWeekStart(
            from: dateRange.firstDate,
            calendar: calendar
        )
        
        let actualWeeks = calculateActualWeeks(
            baseWeekStart: baseWeekStart,
            lastDate: dateRange.lastDate,
            maximumWeeks: maxWeeks,
            calendar: calendar
        )
        
        let weekRanges = makeWeekRanges(
            baseWeekStart: baseWeekStart,
            lastDate: dateRange.lastDate,
            totalWeeks: actualWeeks,
            calendar: calendar
        )
        
        let topAddresses = makeTopAddresses(maxAddressCount: maxAddressCount)
        
        return topAddresses.map { address in
            let allSeries = hourlySeriesForAllWeekdays(
                for: address,
                baseWeekStart: baseWeekStart,
                maxWeeks: actualWeeks
            )
            
            let today = Date()
            let weekdayValue = calendar.component(.weekday, from: today)
            let initialWeekday = Weekday(systemWeekday: weekdayValue) ?? .mon
            
            return CellChartData(
                address: address,
                allSeries: allSeries,
                weekRanges: weekRanges,
                initialWeekday: initialWeekday,
                selectedWeekday: initialWeekday
            )
        }
    }
    
    /// 특정 주소에 대해, 주차·요일·시간별 방문 횟수를 `HourlyVisit` 시리즈로 생성합니다.
    ///
    /// - Parameters:
    ///   - address: 대상이 되는 셀타워 주소
    ///   - baseWeekStart: 주차 계산의 기준이 되는 시작 날짜
    ///   - maxWeeks: 생성할 최대 주차 수
    /// - Returns: 주차·요일·시간별 방문 빈도를 담은 `HourlyVisit` 배열
    func hourlySeriesForAllWeekdays(
        for address: String,
        baseWeekStart: Date,
        maxWeeks: Int
    ) -> [HourlyVisit] {
        let normalizedAddress = address.isEmpty ? "기지국 주소" : address
        
        let buckets = makeHourlyVisitBuckets(
            normalizedAddress: normalizedAddress,
            baseWeekStart: baseWeekStart,
            maximumWeeks: maxWeeks
        )
        
        let validWeeks = buckets.keys.sorted()
        
        return buildHourlyVisits(
            buckets: buckets,
            validWeeks: validWeeks
        )
    }
}

// MARK: - Private Extensions

private extension Array<Location> {
    /// 기지국(LocationType == 2) 데이터만을 대상으로 주소별 체류 시간, 평균 좌표, 방문 빈도를 집계합니다.
    ///
    /// - Parameter sampleIntervalMinutes: 한 샘플이 의미하는 시간(분 단위, 기본값 5분)
    /// - Returns: 주소별 요약 정보 `StayAddress` 배열
    func summarizedStays(sampleIntervalMinutes: Int = 5) -> [StayAddress] {
        let cellTowerLocations = filterCellTowerLocations()
        guard !cellTowerLocations.isEmpty else { return [] }
        
        let staysBucket = makeStaysBucket(from: cellTowerLocations)
        let visitFrequencyByAddress = visitFrequencyByAddress()
        
        return convertBucketToStayAddresses(
            bucket: staysBucket,
            sampleIntervalMinutes: sampleIntervalMinutes,
            visitFrequencyByAddress: visitFrequencyByAddress
        )
    }
    
    /// Location 배열에서 기지국(LocationType == 2) 데이터만 필터링합니다.
    func filterCellTowerLocations() -> [Location] {
        filter { $0.locationType == 2 }
    }
    
    /// Location의 주소를 집계 키로 사용할 수 있도록 정규화합니다.
    func makeAddressKey(for location: Location) -> String {
        location.address.isEmpty ? "기지국 주소" : location.address
    }
    
    /// 주소별 체류 시간과 좌표 합계를 계산하는 버킷을 생성합니다.
    ///
    /// - Parameter locations: 집계 대상 Location 배열
    /// - Returns: 주소별 샘플 수와 위도·경도 합계를 담은 딕셔너리
    func makeStaysBucket(
        from locations: [Location]
    ) -> [String: (sampleCount: Int, latitudeSum: Double, longitudeSum: Double)] {
        var bucket: [String: (sampleCount: Int, latitudeSum: Double, longitudeSum: Double)] = [:]
        
        for location in locations {
            let addressKey = makeAddressKey(for: location)
            
            var entry = bucket[addressKey]
                ?? (sampleCount: 0, latitudeSum: 0, longitudeSum: 0)
            
            entry.sampleCount += 1
            entry.latitudeSum += location.pointLatitude
            entry.longitudeSum += location.pointLongitude
            
            bucket[addressKey] = entry
        }
        
        return bucket
    }
    
    /// 주소별 버킷과 방문 빈도 정보를 `StayAddress` 배열로 변환합니다.
    ///
    /// - Parameters:
    ///   - bucket: 주소별 체류 샘플 수와 좌표 합계 버킷
    ///   - sampleIntervalMinutes: 샘플 간격(분)
    ///   - visitFrequencyByAddress: 주소별 방문 횟수 정보
    /// - Returns: 주소별 체류 요약 배열
    func convertBucketToStayAddresses(
        bucket: [String: (sampleCount: Int, latitudeSum: Double, longitudeSum: Double)],
        sampleIntervalMinutes: Int,
        visitFrequencyByAddress: [String: Int]
    ) -> [StayAddress] {
        bucket.map { address, value in
            let averageLatitude = value.latitudeSum / Double(value.sampleCount)
            let averageLongitude = value.longitudeSum / Double(value.sampleCount)
            let visitCount = visitFrequencyByAddress[address] ?? 0
            
            return StayAddress(
                address: address,
                totalMinutes: value.sampleCount * sampleIntervalMinutes,
                latitude: averageLatitude,
                longitude: averageLongitude,
                visitCount: visitCount
            )
        }
    }
    
    /// 기지국 Location들의 최소·최대 날짜 범위를 계산합니다.
    ///
    /// - Parameter locations: 기지국 Location 배열
    /// - Returns: 최소 날짜와 최대 날짜를 담은 튜플 (없으면 nil)
    func makeCellTowerDateRange(
        from locations: [Location]
    ) -> (firstDate: Date, lastDate: Date)? {
        let dates = locations.compactMap(\.receivedAt)
        guard let firstDate = dates.min(), let lastDate = dates.max() else {
            return nil
        }
        return (firstDate, lastDate)
    }
    
    /// 기준이 되는 "첫 주의 시작일(월요일 00시)"을 계산합니다.
    func makeBaseWeekStart(
        from date: Date,
        calendar: Calendar
    ) -> Date {
        calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
    }
    
    /// 전체 데이터 범위와 최대 주차 수를 바탕으로 실제 사용할 주차 수를 계산합니다.
    ///
    /// - Parameters:
    ///   - baseWeekStart: 기준 주 시작일
    ///   - lastDate: 데이터의 마지막 날짜
    ///   - maximumWeeks: 허용하는 최대 주차 수
    ///   - calendar: 사용 중인 Calendar
    /// - Returns: 실제 사용할 주차 수
    func calculateActualWeeks(
        baseWeekStart: Date,
        lastDate: Date,
        maximumWeeks: Int,
        calendar: Calendar
    ) -> Int {
        let dayDifference = calendar.dateComponents(
            [.day],
            from: baseWeekStart,
            to: lastDate
        ).day ?? 0
        
        return Swift.min(maximumWeeks, dayDifference / 7 + 1)
    }
    
    /// 주차 인덱스별 "MM/dd~MM/dd" 형식의 문자열을 생성합니다.
    ///
    /// - Parameters:
    ///   - baseWeekStart: 기준 주 시작일
    ///   - lastDate: 데이터의 마지막 날짜
    ///   - totalWeeks: 생성할 주차 수
    ///   - calendar: 사용 중인 Calendar
    /// - Returns: 주차 인덱스별 기간 문자열 딕셔너리
    func makeWeekRanges(
        baseWeekStart: Date,
        lastDate: Date,
        totalWeeks: Int,
        calendar: Calendar
    ) -> [Int: String] {
        var weekRanges: [Int: String] = [:]
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "M/d"
        
        for weekIndex in 1 ... totalWeeks {
            guard let weekStart = calendar.date(
                byAdding: .day,
                value: (weekIndex - 1) * 7,
                to: baseWeekStart
            ) else { continue }
            
            let weekEndCandidate = calendar.date(
                byAdding: .day,
                value: 6,
                to: weekStart
            ) ?? weekStart
            
            let weekEnd = Swift.min(weekEndCandidate, lastDate)
            
            let startString = dateFormatter.string(from: weekStart)
            let endString = dateFormatter.string(from: weekEnd)
            
            weekRanges[weekIndex] = "\(startString)~\(endString)"
        }
        
        return weekRanges
    }
    
    /// 체류 시간 기준 상위 주소 목록을 추출합니다.
    func makeTopAddresses(
        maxAddressCount: Int
    ) -> [String] {
        summarizedStays()
            .sorted { $0.totalMinutes > $1.totalMinutes }
            .prefix(maxAddressCount)
            .map(\.address)
    }
    
    /// 주소별·주차별·요일별·시간별 방문 횟수 버킷을 생성합니다.
    ///
    /// - Parameters:
    ///   - normalizedAddress: 정규화된 주소 문자열
    ///   - baseWeekStart: 기준 주 시작일
    ///   - maximumWeeks: 허용 최대 주차 수
    /// - Returns: 주차 인덱스 → 요일 → 시간대별 카운트 버킷
    func makeHourlyVisitBuckets(
        normalizedAddress: String,
        baseWeekStart: Date,
        maximumWeeks: Int
    ) -> [Int: [Weekday: [Int: Int]]] {
        var buckets: [Int: [Weekday: [Int: Int]]] = [:]
        let calendar = Calendar.current
        
        for location in self where location.locationType == 2 {
            guard
                makeAddressKey(for: location) == normalizedAddress,
                let timestamp = location.receivedAt
            else { continue }
            
            let daysFromBase = calendar.dateComponents(
                [.day],
                from: baseWeekStart,
                to: timestamp
            ).day ?? 0
            
            let weekIndex = daysFromBase / 7 + 1
            guard (1 ... maximumWeeks).contains(weekIndex) else { continue }
            
            guard let weekday = Weekday(
                systemWeekday: calendar.component(.weekday, from: timestamp)
            ) else {
                continue
            }
            
            let hour = calendar.component(.hour, from: timestamp)
            
            buckets[weekIndex, default: [:]][weekday, default: [:]][hour, default: 0] += 1
        }
        
        return buckets
    }
    
    /// 버킷 정보를 기반으로 `HourlyVisit` 배열을 생성합니다.
    ///
    /// - Parameters:
    ///   - buckets: 주차·요일·시간별 방문 횟수 버킷
    ///   - validWeeks: 실제로 존재하는 주차 인덱스 목록
    /// - Returns: 모든 주차·요일·시간대 조합을 포함하는 `HourlyVisit` 배열
    func buildHourlyVisits(
        buckets: [Int: [Weekday: [Int: Int]]],
        validWeeks: [Int]
    ) -> [HourlyVisit] {
        validWeeks.flatMap { weekIndex in
            Weekday.allCases.flatMap { weekday in
                (0 ... 23).map { hour in
                    HourlyVisit(
                        weekIndex: weekIndex,
                        weekday: weekday,
                        hour: hour,
                        count: buckets[weekIndex]?[weekday]?[hour] ?? 0
                    )
                }
            }
        }
    }
}
