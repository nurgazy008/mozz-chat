# Инструкция по коммитам в GitHub

Выполните следующие команды для создания коммитов:

```bash
# 1. Добавить базовые файлы проекта
git add .gitignore
git add pubspec.yaml
git add analysis_options.yaml
git commit -m "Initial project setup"

# 2. Добавить модели данных
git add lib/models/
git commit -m "Add data models (User, Message, Chat)"

# 3. Добавить утилиты
git add lib/utils/
git commit -m "Add utility classes (DateFormatter, AvatarHelper)"

# 4. Добавить сервис
git add lib/services/
git commit -m "Add ChatService with Firebase Firestore integration"

# 5. Добавить экраны
git add lib/screens/
git commit -m "Add ChatsScreen and ChatScreen"

# 6. Добавить main.dart
git add lib/main.dart
git commit -m "Add main app entry point with Firebase initialization"

# 7. Добавить конфигурацию Android
git add android/
git commit -m "Configure Android build with Google Services"

# 8. Добавить документацию
git add README.md FIREBASE_SETUP.md
git commit -m "Add project documentation"

# 9. Отправить в репозиторий
git push origin main
```

**Важно:** Не коммитьте `google-services.json` - он уже в .gitignore


