# Azərbaycan Xəbərləri (Flutter App)

Bu layihə Android cihazlar üçün xəbər aqreqatoru və Google AdMob Adaptive Banner reklam modelidir.

## 1. Telefona birbaşa yükləmək üçün (.apk):
Əgər kompüterinizdə Flutter quraşdırılıbsa, bu qovluqda terminalda icra edin:
```bash
flutter pub get
flutter build apk --release
```
Hazır fayl burada yaranacaq:
`build/app/outputs/flutter-apk/app-release.apk`
Bu faylı telefonunuza göndərib birbaşa quraşdıra bilərsiniz.

## 2. Google Play Store üçün (.aab faylı):
Play Store-a yükləmək üçün:
```bash
flutter build appbundle --release
```
Hazır fayl burada yaranacaq:
`build/app/outputs/bundle/release/app-release.aab`

## 3. Kompüterdə Flutter yoxdursa (GitHub Actions ilə pulsuz build):
1. Bu arxivdəki faylları öz GitHub hesabınızda yeni bir repozitoriyaya yükləyin (Push edin).
2. Daxildəki `.github/workflows/build_apk.yml` skripti avtomatik işə düşəcək.
3. 3-4 dəqiqə ərzində "Actions" bölməsində həm **.apk** (telefon üçün), həm də **.aab** (Play Store üçün) faylı hazır yükləmə linki şəklində sizə veriləcək!
