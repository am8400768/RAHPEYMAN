# رهپیمان (Rahpeyman)

اپلیکیشن همراه مهندسین — از آموزش تا اجرا.

ماژول‌ها:

| ماژول | توضیح |
|---|---|
| دوره‌های آموزشی | محتوای ویدئویی با اشتراک (ZarinPal) و ویدئوی امن از S3/CloudFront |
| شرایط عمومی پیمان | مطالعه و جستجوی مواد، آفلاین |
| استفساریه‌ها | پرسش‌وپاسخ‌های فنی نظام فنی، آفلاین |
| مهندس‌یار | ماشین‌حساب مهندسی، لوله‌یار، پروفیل‌یار، آجریار، سیمانیار و… |
| لیستوفریار | متره و برآورد میلگرد، درخت پروژه، گزارش‌گیری و خروجی |

## ساختار پروژه

```
lib/                      # اپلیکیشن Flutter اصلی
  core/                   # تنظیمات، سرویس‌ها، تم، ابزارها
  features/               # auth (OTP) و دوره‌ها
  modules/                # ماژول‌های کسب‌وکار (مهندس‌یار، استفساریه…)
backend/                  # API با FastAPI + PostgreSQL + Redis
  app/                    # کد اصلی (api, core, db, models, services)
  alembic/                # مهاجرت‌های دیتابیس (Alembic)
  tests/                  # تست‌های pytest
website/                  # فرانت‌اند وب مستقل (JavaScript خام)
mobile/                   # پروتوتایپ قدیمی — مرجع، در بیلد استفاده نمی‌شود
```

## اجرای بک‌اند

پیش‌نیاز: Docker (یا Python 3.11 + PostgreSQL + Redis).

```bash
cd backend
cp .env.example .env          # سپس مقادیر واقعی (JWT_SECRET و…) را تنظیم کنید
docker compose up --build -d  # API + PostgreSQL + Redis
docker compose exec api alembic upgrade head
```

بدون Docker (محلی):

```bash
cd backend
pip install -r requirements-dev.txt
alembic upgrade head
uvicorn app.main:app --reload --port 8000
```

مستندات تعاملی API: `http://localhost:8000/docs`

> در حالت `ENV=production` اگر `JWT_SECRET` ضعیف یا کوتاه باشد، سرور از استارت خودداری می‌کند.
> برای ساخت کلید امن: `python -c "import secrets; print(secrets.token_urlsafe(64))"`

## اجرای اپ Flutter

```bash
flutter pub get
flutter run                 # دستگاه/شبیه‌ساز
# یا
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

آدرس API پیش‌فرض: `https://api.rahpeyman.ir` (قابل تغییر با `--dart-define=API_BASE_URL=...`).

### امضای Android Release

فایل `android/app/build.gradle.kts` از `android/key.properties` برای امضای
Release استفاده می‌کند:

```bash
cp android/key.properties.example android/key.properties
# مقادیر keystore واقعی را وارد کنید
```

`key.properties` و فایل‌های keystore در `.gitignore` هستند و **هرگز** commit نمی‌شوند.
بدون این فایل، بیلد Release با کلید debug ساخته می‌شود (فقط برای تست محلی).

## اجرای وب مستقل (website)

```bash
cd website
python3 -m http.server 5500
# آدرس API را در config.js تنظیم کنید
```

## تست‌ها

```bash
# Flutter
flutter analyze && flutter test

# Backend
cd backend && pytest -q
```

## CI

فایل `.github/workflows/ci.yml` در هر push/PR آنالیز و تست Flutter و تست‌های
pytest بک‌اند را اجرا می‌کند.
