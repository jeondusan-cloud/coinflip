# 🪙 결정해줘 (CoinFlip)

동전을 던져서 빠르게 결정하는 Android 앱입니다.

## ✨ 기능

- 🎯 **터치로 동전 던지기** — 화면을 누르고 떼면 동전이 날아갑니다
- ⏱️ **길게 누르기** — 오래 누를수록 동전이 더 많이 회전합니다
- 📳 **햅틱 피드백** — 누를 때와 던질 때 진동으로 반응
- 🎨 **부드러운 애니메이션** — 자연스러운 동전 회전 효과
- 📱 **세로 화면 고정** — 한 손으로 편하게 사용

## 🛠️ 기술 스택

- Flutter (Dart)
- Android SDK 23+ (Android 6.0 이상)

## 🏗️ 빌드 방법

### 사전 준비

1. [Flutter SDK 설치](https://docs.flutter.dev/get-started/install)
2. Android Studio 또는 Android SDK 설치

### 디버그 빌드

```bash
flutter pub get
flutter run
```

### 릴리즈 빌드 (Google Play 출시용)

#### 1. Keystore 생성

```bash
keytool -genkey -v -keystore coinflip-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias coinflip
```

> ⚠️ 생성된 `.jks` 파일과 비밀번호를 안전한 곳에 보관하세요. 분실하면 앱 업데이트가 불가능합니다.

#### 2. key.properties 설정

```bash
cp android/key.properties.template android/key.properties
```

`android/key.properties` 파일을 열고 실제 값을 입력합니다.

#### 3. 앱 아이콘 추가

512x512 PNG 이미지를 `assets/icon/app_icon.png`에 넣습니다.

#### 4. 빌드 실행

```bash
# Windows
build_release.bat

# Mac/Linux
chmod +x build_release.sh
./build_release.sh
```

빌드 결과물: `build/app/outputs/bundle/release/app-release.aab`

## 📄 라이선스

Apache-2.0
