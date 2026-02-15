# تشغيل ترحيل V3 (الأدوار والصلاحيات)

## بيانات الاتصال (من لوحتك)
- **قاعدة البيانات:** `health_office_db`
- **المستخدم:** `health_office_db_user`
- **المنفذ:** `5432`
- **كلمة المرور:** من لوحة الاتصال (حقل Password)

## من جهازك المحلي

يجب استخدام **عنوان الاتصال الخارجي (External / Public)** وليس Internal:

1. من لوحة قاعدة البيانات (مثلاً Render)، انسخ **External Database URL** أو **Host** الخاص بالاتصال من خارج الخدمة.
2. عدّل في السكربت:
   - `run_migration_V3.ps1`: السطر `$env:PGHOST = "العنوان_الخارجي"`
   - `run_migration_V3.bat`: السطر `set PGHOST=العنوان_الخارجي` و `set PGPASSWORD=كلمة_المرور`
3. نفّذ:
   - **PowerShell:** `.\run_migration_V3.ps1` (بعد تنفيذ: `$env:PGPASSWORD = "كلمة_المرور"`)
   - **CMD:** `run_migration_V3.bat`

## من pgAdmin أو DBeaver

1. اتصل بقاعدة البيانات باستخدام **العنوان الخارجي** وكلمة المرور.
2. افتح الملف `migrations/V3__admin_roles_and_permissions.sql`.
3. نفّذ المحتوى (Execute).

## ملاحظة

العنوان `dpg-d68do8er433s73cingco-a` فقط يعمل من داخل شبكة الخدمة. من جهازك استخدم العنوان الكامل الخارجي (مثل `....oregon-postgres.render.com` أو ما يظهر في لوحة التحكم).
