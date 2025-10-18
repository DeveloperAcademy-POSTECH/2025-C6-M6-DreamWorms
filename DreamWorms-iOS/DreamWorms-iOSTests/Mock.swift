//
//  Mock.swift
//  DreamWorms-iOS
//
//  Created by Moo on 10/18/25.
//

import Foundation

/// 테스트에서 사용하는 기지국/위치 관련 메시지 샘플
enum MockMessage {
    /// 숫자 없는 주소
    static let validAddressMessage = """
    [Web발신]
    [발신기지국]
    부산강서구지사동
    1299,284(중계기),06-16
    13:24,N
    """

    /// 주소에 숫자가 포함된 케이스
    static let validAddressWithNumber = """
    [Web발신]
    [발신기지국]
    서울특별시 강남구 역삼1동
    1234,567(중계기),10-18
    14:30,N
    """

    /// 전원이 꺼진(또는 확인 불가) 케이스
    static let powerOffMessage = """
    [Web발신]
    [16,16:13]
    [발신기지국]
    MSC 정보 확인 불가, 전원상태(N)
    [위치자료]
    확인불가
    """
}
