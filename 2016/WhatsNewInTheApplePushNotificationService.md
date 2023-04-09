# [What's New in the Apple Push Notification Service](https://developer.apple.com/videos/play/wwdc2016/724/)

## Review

15년 APNS 개선 사항 리뷰
HTTP/2 provider API
Instant Feedback
Lager payload (4KB 까지)
Simplified certificate handling
HTTP/2 Provider API - Sending Notifications

### HTTP/2 Provider API 과정 요약
![](https://i.imgur.com/RfSrEG7.png)

1. 계정에서 Push notification을 등록합니다.
2. Client App은 디바이스의 OS에 등록됩니다.
3. 디바이스에서는 App을 대신해 토큰을 요청하고 App에 return 됩니다 (디바이스 토큰은 해당 디바이스에서 유일하게 실행 됩니다.)
4. provider 서비스는 client 인증서를 사용해서 APNS와 연결하고 HTTP/2 request를 사용해 디바이스 토큰에 푸시를 전송합니다.
6. HTTP/2 Provider API는 모든 것이 잘 됐을 때 성공을 나타내는 즉각적인 응답을 제공합니다.

## 기존 방식
![](https://i.imgur.com/p9MgUaZ.png)

1. 계정에서 token sign-in key를 선택합니다.
2. provider는 client 인증서없이 TLS 연결을 구성하게 됩니다.
3. 이 연결 상에서 알림을 발송하기 전에 provider는 team ID를 포함한 인증 토큰을 구성합니다.

## 토큰 방식 (NEW)
![](https://i.imgur.com/6Zgx3Yy.png)

1. Signed tokens need to be generated periodically (서명된 토큰은 주기적으로 생성할 필요가 있음)
2. Signing key does not expire (키는 만료되지 않음)
3. Signing key can be revoked through your Account (키는 계정에서 해제할 수 있음)
4. APNs는 인증서 인증을 계속 지원할 것이라고 합니다.

