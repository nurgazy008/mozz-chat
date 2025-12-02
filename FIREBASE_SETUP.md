# Настройка Firebase

## Шаги для настройки Firebase:

1. **Создайте проект в Firebase Console:**
   - Перейдите на https://console.firebase.google.com/
   - Создайте новый проект
   - Добавьте Android приложение (package name: `com.example.mozz`)
   - Добавьте iOS приложение (bundle ID: `com.example.mozz`)

2. **Для Android:**
   - Скачайте `google-services.json`
   - Поместите файл в `android/app/google-services.json`

3. **Для iOS:**
   - Скачайте `GoogleService-Info.plist`
   - Поместите файл в `ios/Runner/GoogleService-Info.plist`

4. **Включите Firestore:**
   - В Firebase Console перейдите в Firestore Database
   - Создайте базу данных в режиме тестового режима
   - Установите правила безопасности (для теста можно разрешить все)

5. **Установите зависимости:**
   ```bash
   flutter pub get
   ```

6. **Запустите приложение:**
   ```bash
   flutter run
   ```

При первом запуске приложение автоматически создаст тестовые данные в Firestore.


