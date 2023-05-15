# WWDC 2020 Deliver a better HLS audio experience

# 들어가기 전에 - HLS가 뭔가요?
애플 기기에서 라이브 스트리밍을 위해 사용되는 규격입니다. HTTP 규격을 따르기 때문에 별도의 처리를 하지 않아도 미디어를 전송할 수 있다네요.
서버에 있는 미디어 파일에 대해 클라이언트가 스트리밍을 요청한다면, 다음과 같은 프로세스를 따릅니다.
- 먼저 서버는 M3U8 형식의 재생목록을 전송합니다. 이 재생목록은 미디어 세그먼트 파일의 URL들이 정렬된 목록을 제공하는 인덱스 파일입니다.
- 클라이언트는 이 재생목록의 각각의 인덱스에 있는 주소에 순서대로 미디어 세그먼트 파일을 요청합니다.
    - HTTP 프로토콜을 따른댔으니까 .GET을 사용하겠죵
- 이 미디어 세그먼트 파일들, 그러니까 "미디어 파일 조각"들이 클라이언트에서 스트리밍됩니다.
예시 코드 보실까요
``` swift
import AVKit
import AVFoundation

let url = URL(string: "http://example.com/stream.m3u8")!
let player = AVPlayer(url: url)
let playerViewController = AVPlayerViewController()
playerViewController.player = player
self.present(playerViewController, animated: true) {
    player.play()
}
```

# 들어가기 전에 - 코덱이 뭔가요?
인코더 + 디코더라고 생각하시면 편합니다.

# 인트로덕션~
데이터 효율성과 HLS 오디오 스트리밍의 음질을 다 잡으려고 했다면, 여기가 당신이 찾던 곳이 맞습니다~
HLS 문서를 함께 보시는 것도 추천.

# 2020년 HLS에서 사용 가능해진 세 가지 포맷(01:29)
## xHE-AAC
eXtended High Efficiency, Advanced Audio Codec. 형용사가 엄청 많이 붙었죠? 개쩌는 코덱이란 뜻임.
특히 낮음~중간 비트 레이트에서 효율이 좋습니다. 200kbps 정도 되는 비트레이트에서요.
파일로써 재생되는 건 19년부터 됐습니다.

MPEG-D USAC(Unified Speech and Audio Coding)라는 또 다른 이름이 있습니다. 
이름에서 보여주듯 굉장히 범용성 있는 코덱이예요~
    특히 속도가 느린 인터넷 환경에서 비교적 매우 좋은 결과물을 냅니다.
    중간 정도 속도에서 더 효율적으로 작동하기는 합니다.

### 기존의 AAC와의 비교
- AAC-LC 코덱
    - HLS 태그상에서는 `CODECS="mp4a.40.2"`로 표현 - 이 표현법은 ISO 표현법이라고 하네요
    - 96kbps 정도의 낮은 데이터 레이트에서 사용할 것을 추천
- HE-AAC 코덱
    - AAC-LC 코덱에서 SBR(Spectral Band Replication)이 추가
        - AAC 미디어 인코딩에 따라, 높은 주파수 성분을 낮은 주파수 성분으로부터 재구축하는 방법이라고 합니다.
    - 48kbps 정도의 더 낮은 데이터 전송률을 가진 환경에서 사용할 것을 추천
    - HLS 태그상에서는 `CODECS="mp4a.40.5"
- HE-AAC v2
    - HE-AAC에서 Parametric Stereo라는 새로운 도구가 추가되었습니다~
        - 모노 채널로부터 스테레오 채널을 만들어내는 매직. 채널 1과 몇 가지 파라메트릭한 값을 통해 채널 2를 구축
    - 더더더 느린 환경, 32kbps 정도의 환경에서 쓰십쇼
    - `CODECS="mp4a.40.29"`
- xHE-AAC
    - 위의 모든 도구들과 달리, 하위호환을 지원하지 않음
        - SBR, PS 같은 비슷한 도구들이 있지만, 이전보다 발전된 형태로 탑재되어 있어 더 효율적.
    - `CODECS="mp4a.40.42"`
    - 24kbps까지 내려가는 환경에서 쓸 수도 있음

### 모든 오디오가 HLS로 스트리밍될 때 포함해야 하는 정보
- 음량 메타데이터
- DRC 메타데이터
    - Dynamic Range Control. 미디어 시스템에 오디오 신호 레벨을 동적으로 조절해, 음원의 다이나믹 레인지를 줄이는 것.
        - 다이나믹 레인지는 가장 큰 소리와 가장 작은 소리 간의 차이를 나타낸다고 보심 됩니다

이걸 포함하지 않으려면? 전송되는 모든 미디어 세그먼트가 같은 음량으로 노멀라이징되어 있어야 함
새로운 ANSI/CTA-2075 과정 하에서도 이 권장 사항은 유효!

이러한 메타데이터들은 CMAF(Common Media Application Format)에 의하면 xHE-AAC에 포함되어야 함
- 기존의 스트리밍 구격인 MPEG-DASH와 HLS 사이의 합일점을 찾고자 하는 시도
- 기존 AAC들에는 머.. 웬만하면 포함해줘요, 정도로 남아 있습니다.
- DRC가 HLS에서 쓰이는 게 점점 중요해지리라는 거~

### 애플 디바이스에서 HLS로 어떻게 쓰나요?
- `CODECS="mp4a.40.42"`
- AVPlayer는 모노와 스테레오 채널 설정을 지원하며, 멀티채널은 지원하지 않습니다.
- fragmented MP4, 즉 fMP4 컨테이너 형식의 파일만이 미디어 "조각"으로써 허용됩니다.
- 표준 암호화 방식만 지원합니다.

이외에 xHE-AAC를 사용할 수 있는 방법은?
- 한정된 비트레이트 하에서 더 좋은 음질을 추구하려면, 다른 AAC와 xHE-AAC를 병기
- 내 플레이리스트에 상술한 DRC 지원 추가하기 - 점점 중요해질 거라고 했죠?
- HLS 태그에 SCORE 애트리뷰트를 추가해서, AVPlayer로 하여금 이 포맷을 사용할 수 있게 하기
    - SCORE에 대한 자세한 사항은 Improve Stream Authoring with HLS Tools를 참조하세요~
예시
```
#EXTM3U

#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=94000,CODECS="mp4a.40.42",SCORE=1.2
aac-he/prog_index.m3u8

#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=96000,CODECS="mp4a,40.2",SCORE=1.1
aac-low/prog_index.m3u8
```

상기 예시는 "재생목록". HLS에서 쓰이는 태그랍니다
코덱 태그를 보면 위에꺼는 xHE-AAC고, 아래꺼는 AAC-LC입니다.
스코어 태그를 보면 위에꺼가 더 높죠? 위에꺼에 더 가중치를 준다는 뜻으로 해석됩니다.
이 가중치를 통해 AVPlayer가 xHE-AAC로 된 위의 예시를 좀 더 우선적으로 채용함을 알 수 있습니다.

## 무손실 오디오 포맷
둘 다 오픈소스 코덱이라고 하네요
FLAC(Free Lossless Audio Codec): 좀더 범용적인 사용
    `CODEC="fLaC"`
Apple Lossless: MPEG-4의 전송을 위한 확실한 수단
    `CODEC="alac"`

- AVPlayer는 상기 포맷들에 대해 최대 8채널까지의 채널 설정을 지원합니다.
    5.1이나 7.1 서라운드 환경까지도 제공을 한단 소리네요?
- fragmented MP4, 즉 fMP4 컨테이너 형식의 파일만이 미디어 "조각"으로써 허용됩니다.
- 표준 암호화 방식만 지원합니다.

### 어떻게 사용할 수 있을까요?
- 비트레이트가 높은 오디오 조각을 재생목록에 포함시킵니다.
    - 쓸 수 있는 주파수 대역폭이 높을 때 (== 인터넷 환경이 좋을 때)
    - 음질이 엄청 중요한 요소일 때

# 멀티채널 오디오 세팅 (18:47)
무손실 포맷일 경우에 적용됩니다~
두 무손실 포맷 모두 5.1과 7.1을 지원한다고 했죠? 
하지만 FLAC과 Apple Lossless의 채널 레이아웃은 좀 다릅니다.
- 쉽게 말해 스피커 배치가 다르다는 거죠 - FLAC에서는 오른쪽 뒤에서 나오는 소리가 Apple Lossless에서는 오른쪽 앞에서 나온다던지 (뇌피셜에 기반한 예시임)
- 애플 무손실은 MPEG을 따라서, 가운데 채널을 먼저 잡습니다. (가운데 왼쪽 오른쪽 ...)
- 반면 FLAC은 SMPTE/ITU-R을 따라서, 왼쪽과 오른쪽을 먼저 잡습니다. (왼쪽 오른쪽 가운데 ...)

또 위에서 봤던 AAC보다 훨씬 큰 데이터 전송률이 필요합니다. 얼마나 더 필요할까요?
- 먼저 기준으로 삼을 AAC-LC 48kHz의 경우 초당 160kbps 정도의 비트레이트가 필요합니다.
- FLAC의 경우, 스테레오 16비트 48kHz 음원의 경우 거의 1mbps 정도 속도가 필요합니다. 24/48이면 1.5mbps 가까이 되고, 하이엔드에 해당하는 24비트 96kHz 음원의 경우 거진 3mbps 속도가 나와야 합니다.
- 지금까지 말한 건 평균! 최악의 경우에는 5.1채널 음원 기준 16/48의 경우 2메가 넘게, 24/96의 경우 8메가 넘게 나와야..

그럼 이 무지막지한 데이터 전송량을 항상 감당할 순 없을텐데, 어떻게 해야 할까요?
- 멀티채널 무손실 포맷은 서비스에 꼭 필요할 경우에만 포함시키도록 합시다.
    - 그리고 이 경우, 멀티채널 AAC도 포함하도록 합시다.
        - 단, 모든 애플 디바이스에서 멀티채널 AAC가 지원되는 것은 아닙니다.
        - 5.1이나 7.1이 지원되지 않는 장비에서는 스테레오로 인코딩이 될겁니다. 하위호환은 지원하지 않습니다..!

위쪽에 미디어 태그가 있는 플레이리스트를 봐 보죠.
```
#EXTM3U
#EXT-X-MEDIA:NAME="Audio",TYPE=AUDIO,GROUP-ID="aac-stereo-high",CHANNELS="2" #EXT-X-MEDIA:NAME="Audio",TYPE-AUDIO,GROUP-ID-"aac-stereo-low",CHANNELS= "2"
#EXT-X-MEDIA:NAME="Audio",TYPE=AUDIO,GROUP-ID-"fLaC-stereo",CHANNELS="2"
#EXT-X-MEDIA:NAME="Audio",TYPE=AUDIO,GROUP-ID="aac-multichannel",CHANNELS="6"
#EXT-X-MEDIA:NAME="Audio",TYPE=AUDIO,GROUP-ID="he-aac-multichannel",CHANNELS="6"
#EXT-X-MEDIA:NAME="Audio",TYPE=AUDIO,GROUP-ID="fLaC-multichannel',CHANNELS="6"

#EXT-X-STREAM-INF:BANDWIDTH=96000,CODECS="mp4a.40.2",AUDIO="aac-stereo-low"
aac-stereo-high/prog_index.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=128000,CODECS-"mp4a.40.2",AUDIO= "aac-stereo-high" aac-stereo-low/prog_index.mu8
#EXT-X-STREAM-INF:BANDWIDTH=200000,CODECS="mp4a.40.5",AUDIO="he-aac-multichannel" he-aac-multichannel/prog_index.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=320000,CODECS="mp4a.40.2",AUDIO="aac-multichannel" aac-multichannel/prog_index.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=1000000,COnFrS="fLaC",AUDIO="fLaC-stereo" 
fLaC-stereo/prog_index.m3u8
#EXT-X-STREAM-INF: BANDWIDTH=2000000,CODECS="fLaC",AUDIO="fLaC-multichannel" fLaC-multichannel/prog_index.m3u8
```

multichannel이 붙어있는 AUDIO 애트리뷰트를 가진 것들이, 풀 채널을 지원하는 환경에서 재생 가능한 녀석들입니다. he-aac 멀티채널부터 무손실까지, 다양한 용량과 음질 비트레이트 환경에 대응할 수 있습니다.
스테레오도 이 경우 마찬가지!
저 중에 포함이 안 된 것들은 대응할 수 없게 됩니다. 무손실 멀티채널 오디오만 있는데, 고갱님이 안 좋은 인터넷 환경에 있다면 스트리밍이 뚝뚝 끊기게 되는 거예요.
