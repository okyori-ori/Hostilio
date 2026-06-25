# Hostilio

Flutter-приложение для управления отелем: номера, бронирования, клиенты и заезд/выезд.

Клиент обращается к PHP REST API (`hotel_api`) и базе данных MariaDB/MySQL.

## Возможности

- Управление номерами: просмотр, добавление, удаление, фильтрация по статусу
- Бронирование номеров с расчётом стоимости
- Учёт клиентов: регистрация, редактирование, удаление, история посещений
- Заезд и выезд: смена статуса номера (Свободен / Занят / На уборке)
- Панель управления с навигацией по разделам

## Требования

| Компонент | Версия |
|-----------|--------|
| Flutter SDK | ≥ 3.11 |
| Dart | ≥ 3.11 |
| XAMPP (Apache + MariaDB + PHP) | 8.x |
| Git | любая актуальная |

Проверка Flutter:

```bash
flutter doctor
```

## Быстрый старт

### 1. Клонирование и зависимости

```bash
cd app/jijijii
flutter pub get
```

### 2. База данных

1. Запустите XAMPP → включите **Apache** и **MySQL**.
2. Откройте phpMyAdmin.
3. Создайте базу `hotel_db` (или импортируйте SQL-скрипт).
4. Выполните SQL из файла:

```
app/Release 12/sqlScript.txt
```

### 3. PHP API (backend)

1. Скопируйте папку `app/Release 12/hotel_api` в `C:\xampp\htdocs\hotel_api`.
2. В файле подключения к БД (`config.php`) укажите:

   - **хост:** `localhost`
   - **база:** `hotel_db`
   - **пользователь:** `root`
   - **пароль:** *(пустой для XAMPP по умолчанию)*

3. Проверьте API в браузере:

   ```
   http://127.0.0.1/hotel_api/rooms.php
   ```

   Должен вернуться JSON со списком номеров.

URL API задан в `app/jijijii/lib/services/api_service.dart`:

```
http://localhost/hotel_api
```

### 4. Запуск приложения

**Windows** (рекомендуется для разработки):

```bash
cd app/jijijii
flutter run -d windows
```

**Web:**

```bash
flutter run -d chrome
```

**Android** (эмулятор или устройство):

```bash
flutter devices
flutter run -d <device_id>
```

> Для Android-эмулятора замените `localhost` в `api_service.dart` на `10.0.2.2`.

## Структура проекта

```
Hostilio-main/
├── app/
│   ├── jijijii/                   # Flutter-приложение
│   │   ├── lib/
│   │   │   ├── main.dart          # Точка входа
│   │   │   ├── models/            # Модели данных (Room, Client, Booking)
│   │   │   ├── screens/           # Экраны приложения
│   │   │   └── services/          # HTTP-клиент (ApiService)
│   │   ├── android/               # Android-платформа
│   │   ├── windows/               # Windows-платформа
│   │   └── pubspec.yaml           # Зависимости
│   └── Release 12/
│       ├── hotel_api/             # PHP REST API
│       │   ├── config.php         # Подключение к БД
│       │   ├── rooms.php          # CRUD номеров
│       │   ├── clients.php        # CRUD клиентов
│       │   ├── bookings.php       # CRUD бронирований
│       │   └── auth.php           # Авторизация (backend)
│       └── sqlScript.txt          # SQL-схема и тестовые данные
└── diagram/                       # UML-диаграммы проекта
```

## Фильтрация номеров

На экране «Номера» доступен фильтр по статусу:

- **Все** — отображаются все номера
- **Свободен** / **Занят** / **На уборке** — только номера с выбранным статусом

## Сборка релиза

```bash
# Windows
flutter build windows

# Android APK
flutter build apk --release

# Web
flutter build web
```

## Устранение неполадок

| Проблема | Решение |
|----------|---------|
| «Ошибка подключения» / «Ошибка сервера» | Проверьте, что Apache запущен и API доступен по URL |
| Пустой список номеров | Убедитесь, что БД импортирована и `rooms.php` возвращает данные |
| Не работает на Android-эмуляторе | Замените `localhost` на `10.0.2.2` в `api_service.dart` |
| `flutter pub get` падает | Выполните `flutter clean && flutter pub get` |
| Бесконечная загрузка (Web) | Убедитесь, что в `config.php` настроены CORS-заголовки |

## Лицензия

Учебный проект. Свободное использование в образовательных целях.
