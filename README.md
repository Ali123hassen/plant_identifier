# 🌿 تطبيق تعرف على النبات

تطبيق Flutter للتعرف على النباتات من خلال الصور مع Laravel API.

## هيكل المشروع

```
plant_identifier_app/          # تطبيق Flutter
├── lib/
│   ├── main.dart              # نقطة البداية
│   ├── models/
│   │   └── plant_model.dart  # نموذج البيانات
│   ├── services/
│   │   └── plant_service.dart # خدمة API
│   └── screens/
│       ├── home_screen.dart      # الشاشة الرئيسية
│       ├── identify_screen.dart # شاشة التعرف
│       ├── result_screen.dart  # شاشة النتيجة
│       └── history_screen.dart # شاشة السجل
└── pubspec.yaml              # تبعيات Flutter

backend/                      # Laravel API
├── app/
│   ├── Http/Controllers/
│   │   └── PlantController.php # تحكم النبات
│   ├── Models/
│   │   └── Plant.php         # نموذج النبات
│   └── Services/
│       └── PlantNetService.php # خدمة PlantNet
├── routes/
│   └── api.php               # المسارات
├── config/
│   └── app.php               # الإعدادات
└── .env                     # متغيرات البيئة
```

## كيفية التشغيل

### 1️⃣ تشغيل Laravel API

```bash
cd backend
composer install
php artisan serve --port=8000
```

### 2️⃣ تشغيل تطبيق Flutter

```bash
cd plant_identifier_app
flutter pub get
flutter run
```

##_API المتاحة

| Method | Endpoint | الوصف |
|--------|----------|-------|
| POST | `/api/v1/identify` | التعرف من ملف صورة |
| POST | `/api/v1/identify/base64` | التعرف من base64 |
| GET | `/api/v1/health` | فحص حالة API |

## متغيرات البيئة

```env
PLANTNET_API_KEY=your_api_key_here
```

## الخدمات المدعومة

- **PlantNet API** - للتعرف على النبات (مجاني)
- يتطلب مفتاح API من [plantnet.org](https://plantnet.org)