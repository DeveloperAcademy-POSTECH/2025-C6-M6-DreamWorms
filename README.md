<img width="1000" height="1080" alt="배경화면" src="https://github.com/user-attachments/assets/e795f92e-08e8-4128-aaf9-9f7750a1f7c1" />

<br>


# 👮‍♂️ 수사24
> 형사들의 신속하고 정확한 추적수사를 위해 피의자 통신 기록과 활동 패턴을 실시간 분석하고 수사 전략을 제안하는 ‘지리적 프로파일링’ 앱

<br>

[![Swift](https://img.shields.io/badge/Swift-6.0-F05138?style=flat&logo=swift&logoColor=white&labelColor=F05138&color=F05138)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-26.0+-000000?style=flat&logo=apple&logoColor=white&labelColor=000000&color=000000)](https://developer.apple.com/ios/)
[![Xcode](https://img.shields.io/badge/Xcode-16.0+-007ACC?style=flat&logo=xcode&logoColor=white&labelColor=007ACC&color=007ACC)](https://developer.apple.com/xcode/)
[![License](https://img.shields.io/badge/License-MIT-4CAF50?style=flat&labelColor=4CAF50&color=4CAF50)](LICENSE)

<br>

## 📆 프로젝트 기간
- 전체 기간: `2025.09.01 ~ 진행중`
- 개발 기간: `2025.11.01 ~ 진행중`

<br>

## 💡 기능

### 0. 사건 분류
> 배정받은 대이동 교제폭력(사건번호 2025-사과1973) 건을 사건목록에 추가합니다.

<img width="6800" height="4320" alt="메인기능 1" src="https://github.com/user-attachments/assets/9676cceb-d035-4bd2-8cdd-c77214283823" />

----

### 1. 메시지에서 위치 데이터 자동 추출
> **App Intent**로 피의자의 통신 기록 메시지를 선택하면, 백그라운드에서 피의자 위치 데이터를 **자동으로 파싱**하여 사건에 즉시 등록합니다.

<img width="6800" height="4320" alt="메인기능 App Intent" src="https://github.com/user-attachments/assets/194b83d0-88ae-4e44-a020-9761e32581af" />

----

### 2. 피의자의 현재위치 확인 & 생활 패턴 분석

> 수사24 **`지도 탭`**에서 피의자의 행적과 현재 위치를 확인해 돌발 행동은 없는지 살핍니다.

<img width="6800" height="4320" alt="메인기능2" src="https://github.com/user-attachments/assets/54d1c455-9228-4b22-b612-62007c0bd1ca" />

----

### 3. 피의자의 수상한 행동 패턴 파악

> 누적 빈도를 통해 피의자가 피해자의 생활 반경 에 자주 접근하는 등 특이 위험 패턴을 파악합니다.

<img width="6800" height="4320" alt="메인기능3" src="https://github.com/user-attachments/assets/e99274ca-e893-4637-9fe8-fa6c7f1b6a45" />


----

### 4. 추가 증거 활용

> 피의자 지인으로부터 `제보받은 증거`(18일, 20일 호텔 이용)를 스캔해서 등록하고 난 뒤 지도에서 `장소 별 연관성을 파악`하고, 스토킹 정황을 포착합니다.

<img width="6800" height="4320" alt="메인기능4" src="https://github.com/user-attachments/assets/a1bb1e40-b305-462b-824d-c4012083139d" />

----

### 5. CCTV 수사

> 이제 어떤 의도로 어떤 행동을 하는지 직접 확인하기 위해 cctv를 조사할 차례입니다.
`추적 탭`에서 피해자 생활반경 내의 `CCTV 리스트`를 확인하고 탐문지역을 명확히 좁힙니다.

<img width="6800" height="4320" alt="메인기능5" src="https://github.com/user-attachments/assets/71135810-55d5-4db0-8982-33daa215d6f5" />


----

### 6. 주요 거점 분석

> `애플의 AI모델(파운데이션 모델)`이 한 줄로 요약해주는 `피의자 주요 거점` 분석 결과를 통해 잠복해야할 곳의 `장소와 시간`을 신속 정확하게 확인해서 `검거 전략`을 세울 수 있습니다.

<img width="6800" height="4320" alt="메인기능6" src="https://github.com/user-attachments/assets/55d2bb40-666b-41aa-8e5c-21ee065a9725" />


https://github.com/user-attachments/assets/312d3e54-f710-4a5c-839a-2b13fb9869ab


----

<br>

## 🧱 Architecture
 | Layer | 구성요소 | 설명 |
|:---:|:---:|:---|
| **TCA** | DWStore,DWAction 등 | 단방향 데이터 흐름 기반 커스텀 상태 관리를 위해 Redux 패턴만 차용 |
| **Automation** | App Intents | 메시지 공유 → 위치 데이터 백그라운드 파싱 |
| **Persistence** | Core Data | 사건·용의자·위치 엔티티 영속화 |
| **Data** | Repository | 프로토콜 기반 데이터 접근 추상화 |
| **Navigation** | AppCoordinator | NavigationPath 기반 화면 전환 |

<br>

## 🛠 Tech Stack
### Core Frameworks
![SwiftUI](https://img.shields.io/badge/SwiftUI-007AFF?style=flat&logo=swift&logoColor=white&labelColor=007AFF&color=007AFF)
![CoreData](https://img.shields.io/badge/CoreData-5856D6?style=flat&logo=apple&logoColor=white&labelColor=5856D6&color=5856D6)
![Combine](https://img.shields.io/badge/Combine-FF9500?style=flat&logo=swift&logoColor=white&labelColor=FF9500&color=FF9500)

### Automation
![AppIntents](https://img.shields.io/badge/AppIntents-FF3B30?style=flat&logo=apple&logoColor=white&labelColor=FF3B30&color=FF3B30)

### Media & Vision
![AVFoundation](https://img.shields.io/badge/AVFoundation-34C759?style=flat&logo=apple&logoColor=white&labelColor=34C759&color=34C759)
![Vision](https://img.shields.io/badge/Vision_OCR-5856D6?style=flat&logo=apple&logoColor=white&labelColor=5856D6&color=5856D6)
![Photos](https://img.shields.io/badge/Photos-FF2D55?style=flat&logo=apple&logoColor=white&labelColor=FF2D55&color=FF2D55)

### Location & Maps
![CoreLocation](https://img.shields.io/badge/CoreLocation-007AFF?style=flat&logo=apple&logoColor=white&labelColor=007AFF&color=007AFF)
![NaverMaps](https://img.shields.io/badge/NaverMaps-03C75A?style=flat&logo=naver&logoColor=white&labelColor=03C75A&color=03C75A)

### Artificial Intelligence
![FoundationModels](https://img.shields.io/badge/Apple_Foundation_Models-000000?style=flat&logo=apple&logoColor=white&labelColor=000000&color=000000)

### Environment
![Git](https://img.shields.io/badge/Git-F05033?style=flat&logo=git&logoColor=white&labelColor=F05033&color=F05033)
![GitHub](https://img.shields.io/badge/GitHub-121011?style=flat&logo=github&logoColor=white&labelColor=121011&color=121011)
![Xcode](https://img.shields.io/badge/Xcode-007ACC?style=flat&logo=xcode&logoColor=white&labelColor=007ACC&color=007ACC)

### Communication
<div align="left">
<img src="https://img.shields.io/badge/Miro-FFFC00?style=flat&logo=miro&logoColor=050038&labelColor=FFFC00&color=FFFC00" />
<img src="https://img.shields.io/badge/Notion-000000?style=flat&logo=notion&logoColor=white&labelColor=000000&color=000000" />
<img src="https://img.shields.io/badge/Figma-F24E1E?style=flat&logo=figma&logoColor=white&labelColor=F24E1E&color=F24E1E" />
</div>

<br>

## Team Tech Blog
👉 기술의 성장에 대한 자세한 내용은 [Medium Tech Blog](https://medium.com/%EC%99%95%EA%BF%88%ED%8B%80%EC%9D%B4-dreamworms)를 확인하세요!
