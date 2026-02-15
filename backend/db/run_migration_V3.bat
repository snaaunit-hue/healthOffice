@echo off
chcp 65001 >nul
REM تشغيل ترحيل V3 - ضع كلمة المرور أدناه أو في متغير PGPASSWORD
set PGHOST=dpg-d68do8er433s73cingc0-a.frankfurt-postgres.render.com
set PGPORT=5432
set PGDATABASE=health_office_db
set PGUSER=health_office_db_user
set PGPASSWORD=uiGXHVr4K5CCDWrb8Nn8uvx4Emj6gVq0

set SCRIPT=%~dp0migrations\V3__admin_roles_and_permissions.sql
if not exist "%SCRIPT%" (
    echo الملف غير موجود: %SCRIPT%
    exit /b 1
)

echo تشغيل الترحيل V3...
psql -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -f "%SCRIPT%"
if %ERRORLEVEL% equ 0 (
    echo تم تنفيذ الترحيل بنجاح.
) else (
    echo فشل التنفيذ. تحقق من تشغيل PostgreSQL وبيانات الاتصال.
    exit /b 1
)
