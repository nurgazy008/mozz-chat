# Mozz Messenger

Мессенджер на Flutter с Firebase Firestore.

## Функционал

- Список чатов с поиском
- Экран чата с сообщениями
- Отправка сообщений в реальном времени
- Форматирование дат и времени
- Аватары с инициалами
- Статус "В сети"

## Настройка Firebase

1. Скачайте `google-services.json` из Firebase Console
2. Поместите файл в `android/app/google-services.json`
3. Включите Firestore Database в Firebase Console
4. Установите правила безопасности (для теста можно разрешить все)

Подробная инструкция в `FIREBASE_SETUP.md`

## Запуск

```bash
flutter pub get
flutter run
```

## Сборка APK

```bash
flutter build apk --release
```

APK будет в `build/app/outputs/flutter-apk/app-release.apk`
