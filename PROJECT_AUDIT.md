# بررسی جامع پروژه رهپیمان (Rahpeyman)

تاریخ بررسی: ۲۰۲۵-۰۹-۰۷
وضعیت کلی: **پروژه از نظر ساختار و حجم کد قابل‌توجه است، اما «نیمه‌کاره» و «ناتمام» است.** بخش‌های مهمی (فایل‌های خالی، ماژول‌های placeholder، برندینگ ناتمام، بک‌اند غیرقابل‌اجرا به‌صورت آماده) جلوی انتشار را می‌گیرند.

---

## ۱) 🔴 موارد مسدودکننده (باید قبل از انتشار حل شود)

### ۱٫۱ — ۲۶ فایل Dart خالی (۰ بایت) در لیستوفریار و شرایط عمومی
این فایل‌ها در Git ثبت شده‌اند ولی یک خط کد ندارند:

- `lib/modules/listoferyar/backup/backup_service.dart`
- `lib/modules/listoferyar/backup/restore_service.dart`
- `lib/modules/listoferyar/data/datasources/listoferyar_local_datasource.dart`
- `lib/modules/listoferyar/domain/models/license.dart`
- `lib/modules/listoferyar/domain/repositories/{layer,project,rebar}_repository.dart`
- `lib/modules/listoferyar/domain/services/{layer,project}_service.dart`
- `lib/modules/listoferyar/help/help_content.dart` , `help_service.dart`
- `lib/modules/listoferyar/licensing/license_manager.dart` , `license_repository.dart` , `trial_manager.dart`
- `lib/modules/listoferyar/presentation/controllers/{project,tree}_controller.dart`
- `lib/modules/listoferyar/presentation/dialogs/{delete_confirm,edit_node}_dialog.dart`
- `lib/modules/listoferyar/presentation/screens/{help,license}_screen.dart`
- `lib/modules/listoferyar/presentation/widgets/{project_card,project_info_card,quick_navigation_bar}.dart`
- `lib/modules/listoferyar/services/listoferyar_service_locator.dart`
- `lib/modules/sharayet_omoomi_piman/data/sharayet_repository.dart` , `sharayet_search.dart`

**پیامد:** قابلیت‌های «لایسنس/آزمایشی»، «راهنما»، «پشتیبان‌گیری/بازیابی»، «کنترلرهای پروژه و درخت» و «جستجوی شرایط عمومی» عملاً وجود ندارند. صفحه‌ی `license_screen.dart` و `help_screen.dart` خالی است و منوی لیستوفریار هنگام کلیک روی این بخش‌ها یا خطا می‌دهد یا صفحه‌ی خالی باز می‌کند.

**پیشنهاد:** یا این فایل‌ها را کامل بنویسید، یا اگر فعلاً لازم نیستند از پروژه حذف کنید و دکمه‌های مربوطه را غیرفعال/مخفی کنید.

### ۱٫۲ — اپلیکیشن Android در حالت Release اینترنت ندارد
فایل `android/app/src/main/AndroidManifest.xml` **فاقد** `android.permission.INTERNET` است؛ این مجوز فقط در `android/app/src/debug/AndroidManifest.xml` و `src/profile/` وجود دارد. یعنی خروجی Release (Play Store / APK نهایی) **به هیچ API‌ای وصل نمی‌شود** و دوره‌ها، ورود OTP و… همه کار نمی‌کنند.

**پیشنهاد:** افزودن `<uses-permission android:name="android.permission.INTERNET"/>` به manifest اصلی.

### ۱٫۳ — امضای Release با کلید Debug
در `android/app/build.gradle.kts`:

```kotlin
release {
    signingConfig = signingConfigs.getByName("debug")
}
```

با این تنظیم، بیلد Release قابل انتشار در Google Play نیست (امضای debug و نبود keystore اختصاصی).

**پیشنهاد:** ساخت keystore اختصاصی + `key.properties` (در `.gitignore`) و پیکربندی signingConfig از آن.

### ۱٫۴ — بک‌اند با docker-compose فعلی بالا نمی‌آید
`backend/docker-compose.yml` فقط Redis دارد؛ ولی:
- `DATABASE_URL` پیش‌فرض به **PostgreSQL** (`postgresql://user:pass@localhost:5432/rahpeyman`) اشاره می‌کند.
- سرویس PostgreSQL در compose وجود ندارد و فایل `backend/rahpeyman.db` (SQLite) هم اصلاً در کد استفاده نمی‌شود.
- هیچ `Dockerfile` یا فایل استقرار (Render/Fly/Hostinger و…) وجود ندارد.

**پیشنهاد:** افزودن سرویس Postgres به compose + فایل `Dockerfile` + مستندسازی اجرا.

### ۱٫۵ — الگوی مهاجرت‌ها ناقص است
- `backend/migrations/` از `002_...` شروع می‌شود؛ فایل `001_initial.sql` وجود ندارد.
- با وجود `alembic` در `requirements.txt`، هیچ `alembic.ini` / `env.py` / `versions/` وجود ندارد؛ یعنی مهاجرت‌ها فقط SQLهای خام هستند و به‌صورت خودکار اجرا نمی‌شوند.
- ساخت جداول در `main.py` با `Base.metadata.create_all` انجام می‌شود که در تولید (production) اصلاً روش درستی نیست (تغییرات schema را اعمال نمی‌کند).

**پیشنهاد:** راه‌اندازی Alembic واقعی + نوشتن `001_initial` و تبدیل فایل‌های ۰۰۲ تا ۰۰۵ به revهای مناسب.

---

## ۲) 🟠 بخش‌های نیمه‌کاره / Mock

| بخش | وضعیت |
|---|---|
| `lib/features/auth/screens/login_screen.dart` | **کاملاً Mock است** (`// فعلاً mock — بعداً به API/Session واقعی وصل می‌شود` + `Future.delayed`). ورود با نام کاربری/رمز در بک‌اند هم پیاده‌سازی نشده (فقط OTP). `forgot_password_screen.dart` هم صرفاً UI است. |
| دوره‌ها | بک‌اند موبایل و وب جدا نوشته شده‌اند؛ پخش ویدئو فقط `stream_url` برمی‌گرداند؛ کوئری پخش محافظت‌شده (signed URL) هست ولی صفحه‌ی پخش در موبایل پیاده‌سازی نشده (فقط در `mobile/` قدیمی `secure_video_player.dart` هست). |
| «اطلاعیه‌ها»، «درباره ما»، «علاقه‌مندی‌ها» | همه به `ModulePlaceholderScreen` می‌روند؛ محتوای واقعی ندارند. |
| لیستوفریار | پروژه/درخت/میلگرد/گزارش کار می‌کند؛ ولی لایسنس، راهنما، پشتیبان‌گیری و کنترلرهای پروژه/درخت **خالی** هستند (فایل‌های ۰ بایت). |
| «مهندس‌یار» | خوب پیش رفته (ماشین‌حساب، لوله‌یار، پروفیل‌یار، آجر، بتن و…). ولی `lib/modules/engineering_assistant/data/pipe_database_service.dart` و `services/pipe_database_service.dart` **کد تکراری** هستند. |
| صفحه‌ی اصلی | به‌عنوان `HomePlaceholderScreen` نام‌گذاری شده و در چند نسخه وجود دارد: `lib/modules/home/…` (اصلی)، `lib/features/home/…` و `lib/modules/engineering_assistant/home/…` (کد مرده). |
| `ModuleNavigator` | با کد مرده استفاده می‌شود؛ هیچ‌کدام از صفحات `features/home` وارد flow اصلی نمی‌شوند. |
| وب (سایت مستقل) | تکمیل‌تر از وب Flutter است ولی مستقل از `lib` نگهداری می‌شود؛ عدم یکپارچگی باعث دوباره‌کاری می‌شود. |
| `mobile/` | پروتوتایپ قدیمی است و در `analysis_options.yaml` حذف شده؛ بهتر است از مخزن اصلی خارج شود. |

---

## ۳) 🟡 بهداشت مخزن و پیکربندی

1. **۸٬۹۵۵ فایل venv در Git ثبت شده** (حدود ۱۶۴ مگابایت): `backend/.venv/` ، `backend/venv/` و `venv/` ریشه. این بزرگ‌ترین مشکل مخزن است. `.gitignore` هیچ الگوی `venv/`/`.venv/` ندارد.
2. **کدهای قالب Flutter**:
   - `flutter_application_1/` (۱۲۹ فایل، اپلیکیشن پیش‌فرض «Flutter Demo») داخل مخزن است.
   - فایل خالی `desktop-tutorial` در ریشه ثبت شده است.
3. **فایل‌های پشتیبان/زباله**: `android/app/build.gradle.kts.ok` ، `android/settings.gradle.kts.ok` ، `lib/modules/engineering_assistant/screens/concrete_calculator_screen.dart.bak` ، `tmp/checklist-qa/page-1.png` ، `Environment_Report.txt` (UTF-16 با متن فارسی خراب).
4. **برندینگ ناتمام**:
   - Android: `applicationId` و `namespace` = `com.example.final_listofer` (باید مثلاً `ir.rahpeyman.app` شود).
   - iOS: `CFBundleDisplayName = Final Listofer` / `CFBundleName = final_listofer`.
   - Web: `<title>final_listofer</title>` و `description: A new Flutter project.` (اینها در `web/index.html` هستند).
5. **pubspec.lock به mirror چینی قفل شده است**: ۸۵ رکورد با URL = `https://pub.flutter-io.cn`. روی سیستم‌های خارج از چین این می‌تواند `pub get` را کند یا بشکند؛ بهتر است به `pub.dev` برگردد.
6. **منابع بدون استفاده**:
   - ۱۱ فونت در `assets/fonts/` در pubspec اعلام نشده‌اند (فقط ۸ فونت استفاده می‌شود)؛ `Dima.Sogand.ttf` هم کپی `Dima.Sogand.New.ttf` است.
   - `assets/data/estefsarieh_data.json` و `estefsarieh_data.sql` در `lib` استفاده نمی‌شوند، ولی در pubspec اعلام شده‌اند. `assets/images/logo/20.png` هم بی‌استفاده است.
   - `lib/` حدود ۳۰٬۷۰۰ خط کد دارد؛ سهم بزرگی از آن‌ها کد تکراری/مرده است.
7. **ناهماهنگی Flutter**: ترکیب `withOpacity` (منسوخ) و `withValues`، نبود `flutter_localizations`/`intl` با وجود UI کاملاً فارسی، `Directionality` دستی در بعضی صفحات و نبود در بعضی دیگر.

---

## ۴) 🔵 امنیت و کیفیت بک‌اند

1. **JWT_SECRET پیش‌فرض ضعیف**: `"your-secret-key-change-this"` در `backend/app/core/config.py`؛ اگر `.env` تنظیم نشود، توکن‌ها جعل‌پذیرند. باید در استارت‌آپ در حالت production خطا بدهد.
2. **Redis آدرس هاردکد** (`redis://localhost:6379` در `auth.py`) — قابل پیکربندی نیست و اگر Redis نباشد، `request-otp` با خطای unhandled به ۵۰۰ می‌رسد.
3. **پیامک بی‌صدا** (`sms_service.send_otp_sms`): خطا توسط `requests` خورده می‌شود و پاسخ بررسی نمی‌شود؛ کلاینت «کد ارسال شد» می‌گیرد حتی اگر پیامک نرفته باشد.
4. **`login_with_password` در `auth_service.py` وجود دارد ولی در هیچ route صدا زده نمی‌شود**؛ و `login_screen` هم Mock است → مسیر رمز عبور عملاً مرده است.
5. **`verify_token` در `security.py`** فقط `JWTError` را می‌گیرد؛ `int(payload.get("sub"))` با ورودی نامعتبر (مثل رشته‌ی غیرعددی) در `dependencies.py` به `ValueError` → ۵۰۰ می‌انجامد.
6. **`@app.on_event("startup")`** منسوخ (deprecated) است → باید `lifespan` استفاده شود.
7. **`has_active_subscription` و توکن‌ها از `datetime.utcnow()`** استفاده می‌کنند (منسوخ/naive) — پیشنهاد `datetime.now(timezone.utc)` و یکدستی با ستون‌های DB.
8. **CloudFront** در `.env.example` تعریف شده ولی در `VideoService` هرگز استفاده نمی‌شود (فقط S3 presigned URL).
9. **احتمال مشکل passlib + bcrypt**: `requirements.txt` می‌گوید `passlib[bcrypt]==1.7.4` در حالی که `bcrypt==5.0.0` نصب شده؛ ترکیب شناخته‌شده‌ی ناسازگار (خطای `module 'bcrypt' has no attribute '__about__'` در زمان ساخت CryptContext). چون مسیر رمز عبور استفاده نمی‌شود فعلاً فعال نمی‌شود، ولی بومب ساعتی است.
10. **عدم وجود**: endpoint سلامت (`/health`)، rate-limit کلی (فقط OTP دارد)، لاگ ساخت‌یافته (با اینکه `structlog` در requirements است)، مدیریت توکن Revocation، و رمزنگاری نگهداری `attestation_token` (فقط hash می‌شود — خوب است).

---

## ۵) 🔵 تست، CI، مستندسازی

- **Test:** فقط یک `test/widget_test.dart` (اسموک‌تست) و **صفر تست برای بک‌اند** (نه pytest، نه httpx TestClient، نه تست ماژول‌های Flutter).
- **CI:** هیچ `.github/workflows/` وجود ندارد (نه lint، نه test، نه build).
- **README.md:** هنوز متن پیش‌فرض قالب Flutter است («A new Flutter project.») — هیچ توضیحی درباره‌ی معماری، اجرا، `.env`، مهاجرت‌ها یا استقرار ندارد.
- **License:** فایل `LICENSE` وجود ندارد.
- **دستورهای dev:** `rahpeyman_bot.ps1` مسیرهای هاردکد ویندوزی (`D:\Projects\Rahpeyman`, `Pixel_7`) دارد و برای دیگران قابل استفاده نیست؛ می‌توان به `Makefile` / اسکریپت کراس‌پلتفرم تبدیلش کرد.

---

## ۶) خلاصه‌ی اولویت‌بندی پیشنهادی

| اولویت | کار | اثر |
|---|---|---|
| ۱ | افزودن `INTERNET` به manifest اصلی + keystore واقعی | خروجی Release قابل استفاده/انتشار |
| ۲ | حذف venvها از Git + به‌روزرسانی `.gitignore` | مخزن از ۱۷۵MB به چند MB |
| ۳ | تکمیل یا حذف ۲۶ فایل Dart خالی لیستوفریار/شرایط عمومی | رفع باگ‌های ناوبری |
| ۴ | Postgres در compose + Dockerfile + Alembic (init) | بک‌اند out-of-the-box اجرا شود |
| ۵ | اجباری‌کردن `JWT_SECRET` در production + Redis از env | امنیت |
| ۶ | یکپارچه‌سازی برندینگ (applicationId، iOS، Web) و بازنویسی README | آماده‌ی انتشار |
| ۷ | اتصال Login واقعی + تکمیل مسیر پرداخت/اشتراک در اپ | چرخه‌ی کاربر کامل |
| ۸ | تست‌های پایتون + تست ویجت ماژول‌ها + CI | کیفیت و نگهداشت |
| ۹ | پاک‌سازی کد مرده (FeaturesHome، مهندس‌یار Home، mobile/، mirror چین) | تمیزی پروژه |

---

## ۷) آمار مشاهده‌شده

- کل فایل‌های ثبت‌شده در Git: ~۹٬۴۱۲ (که ~۸٬۹۵۵ فایل آن venv است)
- حجم مخزن: ~۱۷۵MB (مخزن واقعی کد ~۱۰MB)
- کد Dart `lib/`: ~۳۰٬۷۰۰ خط؛ کد Python بک‌اند: ~۴۰۰+ خط API
- جداول DB: `users, courses, videos, device_registrations, payments` (همه خالی)
- مهاجرت‌ها: ۴ فایل (۰۰۲ تا ۰۰۵)، بدون init و بدون Alembic

---

## ۸) ✅ اصلاحات انجام‌شده (۲۰۲۵-۰۹-۰۷)

| # | مشکل | راه‌حل |
|---|---|---|
| ۱ | مجوز INTERNET فقط در Debug | به `android/app/src/main/AndroidManifest.xml` اضافه شد |
| ۲ | امضای Release با کلید Debug | `build.gradle.kts` از `android/key.properties` می‌خواند + `key.properties.example` و بک‌آپ debug برای بیلد محلی |
| ۳ | پکیج `com.example.final_listofer` | به `ir.rahpeyman.app` تغییر کرد (Android namespace/applicationId، MainActivity، iOS bundle id، macOS، TEST_HOST) |
| ۴ | برندینگ ناتمام | iOS/Web/macOS/windows/linux → «رهپیمان» / `rahpeyman`؛ `web/manifest.json` بازنویسی شد |
| ۵ | venvها داخل Git (۸۹۵۵ فایل) | از index حذف شدند + الگوهای `venv/`، `.venv/`، `.env`، `*.db`، keystore به `.gitignore` اضافه شد |
| ۶ | فایل‌های زباله/کد مرده | حذف: `flutter_application_1`، `tmp/`، `Environment_Report.txt`، `desktop-tutorial`، `.ok`/`.bak`، `rahpeyman.db`، ۲۶ فایل Dart خالی، `features/home`، `login/forgot` mock، سرویس تکراری لوله‌یار |
| ۷ | mirror چینی `pub.flutter-io.cn` | تمام ۸۵ آدرس قفل‌شده به `pub.dev` برگشت |
| ۸ | assets بدون استفاده | `estefsarieh_data.{json,sql}` از pubspec حذف شد |
| ۹ | JWT_SECRET ضعیف/پیش‌فرض | `config.py` در `ENV=production` با کلید ضعیف/کوتاه استارت نمی‌خورد |
| ۱۰ | Redis هاردکد | `REDIS_URL` از env خوانده می‌شود (`auth.py`) + خطای Redis → 503 |
| ۱۱ | خطای پیامک نادیده | `send_otp_sms` بررسی می‌شود؛ شکست پیامک → 502 (به‌جای «ارسال شد» دروغین) |
| ۱۲ | token با `sub` نامعتبر → 500 | `dependencies.py` با TypeError/ValueError → 401 |
| ۱۳ | `@app.on_event` منسوخ | به `lifespan` تبدیل شد |
| ۱۴ | بدون `/health` | `app/api/health.py` + تست |
| ۱۵ | passlib/bcrypt ناسازگار | `bcrypt==4.0.1` در requirements پین شد |
| ۱۶ | Postgres/Redis در compose | `docker-compose.yml` بازنویسی شد: api + postgres (با healthcheck) + redis |
| ۱۷ | بدون Dockerfile | `backend/Dockerfile` + `.dockerignore` |
| ۱۸ | مهاجرت‌های دستی بدون init | Alembic راه‌اندازی شد: `alembic.ini`، `env.py`، `script.py.mako`، `versions/001_initial_tables.py` (کل اسکیمای فعلی)؛ SQLهای قدیمی حذف و README جایگزین شد |
| ۱۹ | صفر تست بک‌اند | `backend/tests/`: ۳ فایل تست (امنیت، AuthService، Health) + `requirements-dev.txt` — **۱۷ تست پاس** ✅ |
| ۲۰ | بدون CI | `.github/workflows/ci.yml` (flutter analyze/test + pytest) |
| ۲۱ | README پیش‌فرض | بازنویسی کامل به فارسی (معماری، اجرا، docker، alembic، امضا، تست) |
