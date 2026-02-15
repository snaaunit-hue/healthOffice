# تشغيل ترحيل V3 (admin_roles) على PostgreSQL
# ضع كلمة المرور في المتغير أدناه أو نفّذ: $env:PGPASSWORD = "كلمة_المرور"

$env:PGHOST = "dpg-d68do8er433s73cingc0-a.frankfurt-postgres.render.com"
$env:PGPORT = "5432"
$env:PGDATABASE = "health_office_db"
$env:PGUSER = "health_office_db_user"
if (-not $env:PGPASSWORD) { $env:PGPASSWORD = "uiGXHVr4K5CCDWrb8Nn8uvx4Emj6gVq0" }

$scriptPath = Join-Path $PSScriptRoot "migrations\V3__admin_roles_and_permissions.sql"
if (-not (Test-Path $scriptPath)) {
    Write-Error "الملف غير موجود: $scriptPath"
    exit 1
}

Write-Host "تشغيل الترحيل V3 من: $scriptPath" -ForegroundColor Cyan
& psql -h $env:PGHOST -p $env:PGPORT -U $env:PGUSER -d $env:PGDATABASE -f $scriptPath
if ($LASTEXITCODE -eq 0) {
    Write-Host "تم تنفيذ الترحيل بنجاح." -ForegroundColor Green
} else {
    Write-Host "فشل التنفيذ. تحقق من تشغيل PostgreSQL وبيانات الاتصال." -ForegroundColor Red
    exit $LASTEXITCODE
}
