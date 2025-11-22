# iOS Build Guide for Cloud Mac

Since you have a Cloud Mac, you can build and run the iOS version of this Flutter app. Follow these steps:

## 1. Prerequisites on the Mac
Ensure the following are installed on your Cloud Mac:
- **Xcode**: Install from the Mac App Store.
- **Flutter SDK**: [Install Flutter](https://docs.flutter.dev/get-started/install/macos).
- **CocoaPods**: Run `sudo gem install cocoapods` in the terminal.

## 2. Get the Code
Clone the repository to your Mac:
```bash
git clone https://github.com/rakeshgeddam/mobile_application_serenity.git
cd mobile_application_serenity
```

## 3. Install Dependencies
Run the following commands in the project root:
```bash
flutter pub get
cd ios
pod install
cd ..
```

## 4. Open in Xcode
You can open the iOS project in Xcode to build and run:
1. Open Xcode.
2. Click **Open...**
3. Navigate to `mobile_application_serenity/ios` and select `Runner.xcworkspace`.

## 5. Build and Run
1. In Xcode, select a simulator (e.g., iPhone 15) or your connected device from the top bar.
2. Press the **Play** button (or `Cmd + R`) to build and run the app.

## Troubleshooting
- **Signing Issues**: If you want to run on a physical device, you'll need to sign in with your Apple ID in Xcode (Settings > Accounts) and select your Team in the **Runner** target settings under **Signing & Capabilities**.
- **Pod Issues**: If you encounter issues with Pods, try running:
  ```bash
  cd ios
  rm -rf Pods
  rm Podfile.lock
  pod install --repo-update
  ```
