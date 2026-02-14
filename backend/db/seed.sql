-- Seed data for Health Office portal (demo environment)

INSERT INTO roles (code, name_ar, name_en)
VALUES
    ('LICENSING_OFFICER', N'موظف التراخيص', 'Licensing Officer'),
    ('INSPECTOR', N'مفتش', 'Inspector'),
    ('FINANCIAL_OFFICER', N'موظف مالي', 'Financial Officer'),
    ('DEPARTMENT_HEAD', N'مدير الإدارة', 'Department Head'),
    ('SYSTEM_ADMIN', N'مسؤول النظام', 'System Administrator')
ON CONFLICT (code) DO NOTHING;

INSERT INTO permissions (code, description_ar, description_en)
VALUES
    ('APPLICATION_REVIEW', N'مراجعة طلبات التراخيص', 'Review license applications'),
    ('INSPECTION_MANAGE', N'إدارة الزيارات التفتيشية', 'Manage inspections'),
    ('PAYMENT_MANAGE', N'إدارة المدفوعات المالية', 'Manage payments'),
    ('LICENSE_ISSUE', N'إصدار التراخيص', 'Issue licenses'),
    ('USER_MANAGE', N'إدارة المستخدمين', 'Manage users'),
    ('SETTINGS_MANAGE', N'إدارة إعدادات النظام', 'Manage system settings')
ON CONFLICT (code) DO NOTHING;

-- Basic role-permission mapping (example)
-- SYSTEM_ADMIN gets all permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.code = 'SYSTEM_ADMIN'
ON CONFLICT DO NOTHING;

-- LICENSING_OFFICER
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('APPLICATION_REVIEW', 'LICENSE_ISSUE')
WHERE r.code = 'LICENSING_OFFICER'
ON CONFLICT DO NOTHING;

-- INSPECTOR
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('INSPECTION_MANAGE')
WHERE r.code = 'INSPECTOR'
ON CONFLICT DO NOTHING;

-- FINANCIAL_OFFICER
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('PAYMENT_MANAGE')
WHERE r.code = 'FINANCIAL_OFFICER'
ON CONFLICT DO NOTHING;

-- DEPARTMENT_HEAD
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('APPLICATION_REVIEW', 'INSPECTION_MANAGE', 'LICENSE_ISSUE', 'PAYMENT_MANAGE')
WHERE r.code = 'DEPARTMENT_HEAD'
ON CONFLICT DO NOTHING;

-- Demo facility
INSERT INTO facilities (facility_code, name_ar, name_en, facility_type, license_type, district, area, street, property_owner, rooms_count)
VALUES (
    'FAC-0001',
    N'مستشفى العاصمة النموذجي',
    'Capital Model Hospital',
    'HOSPITAL',
    'NEW',
    N'الوحدة',
    N'الحي الطبي',
    N'شارع المستشفى',
    N'شركة الاستثمار الطبي',
    25
)
ON CONFLICT (facility_code) DO NOTHING;

-- Demo facility user (owner) - password hash placeholder (BCrypt)
INSERT INTO facility_users (facility_id, full_name, phone_number, email, national_id, user_type, password_hash)
SELECT id,
       N'د. أحمد علي',
       '+967700000000',
       'owner@example.com',
       '01010101010',
       'OWNER',
       '$2a$10$REPLACE_WITH_REAL_BCRYPT_HASH'
FROM facilities
WHERE facility_code = 'FAC-0001'
ON CONFLICT DO NOTHING;

-- Demo admin user
INSERT INTO admins (full_name, username, password_hash, phone_number, email, role_id)
SELECT
    N'مسؤول النظام التجريبي',
    'admin',
    '$2a$10$REPLACE_WITH_REAL_BCRYPT_HASH',
    '+967711111111',
    'admin@example.com',
    (SELECT id FROM roles WHERE code = 'SYSTEM_ADMIN')
WHERE NOT EXISTS (SELECT 1 FROM admins WHERE username = 'admin');

-- Demo application
INSERT INTO applications (application_number, facility_id, submitted_by_user_id, status, license_type, facility_type, created_at, submitted_at)
SELECT
    'APP-0001',
    f.id,
    u.id,
    'UNDER_REVIEW',
    'NEW',
    f.facility_type,
    NOW() - INTERVAL '5 days',
    NOW() - INTERVAL '4 days'
FROM facilities f
JOIN facility_users u ON u.facility_id = f.id
WHERE f.facility_code = 'FAC-0001'
ON CONFLICT (application_number) DO NOTHING;

-- Demo inspection
INSERT INTO inspections (application_id, scheduled_date, actual_visit_date, inspector_id, status, overall_score, notes)
SELECT
    a.id,
    NOW() - INTERVAL '3 days',
    NOW() - INTERVAL '3 days',
    (SELECT id FROM admins WHERE username = 'admin'),
    'COMPLETED',
    92.5,
    N'تفتيش مبدئي، المرفق مطابق للاشتراطات الأساسية.'
FROM applications a
WHERE a.application_number = 'APP-0001'
ON CONFLICT DO NOTHING;

-- Demo approval payment and license
INSERT INTO payments (application_id, payment_reference, governorate_code, amount, status, created_at, paid_at, payment_channel)
SELECT
    a.id,
    'PAY-0001',
    'SANA_A_CAPITAL',
    150000.00,
    'PAID',
    NOW() - INTERVAL '2 days',
    NOW() - INTERVAL '2 days',
    'BANK'
FROM applications a
WHERE a.application_number = 'APP-0001'
ON CONFLICT (payment_reference) DO NOTHING;

INSERT INTO licenses (application_id, license_number, issue_date, expiry_date, pdf_url, status, created_at)
SELECT
    a.id,
    'LIC-0001',
    CURRENT_DATE - INTERVAL '2 days',
    CURRENT_DATE + INTERVAL '1 year',
    '/licenses/LIC-0001.pdf',
    'ACTIVE',
    NOW() - INTERVAL '2 days'
FROM applications a
WHERE a.application_number = 'APP-0001'
ON CONFLICT (license_number) DO NOTHING;

-- Demo notification
INSERT INTO notifications (recipient_user_id, title_ar, title_en, body_ar, body_en, type)
SELECT
    u.id,
    N'تم إصدار الترخيص',
    'License issued',
    N'تم إصدار ترخيص المرفق رقم LIC-0001 بنجاح.',
    'License LIC-0001 has been issued successfully.',
    'LICENSE_STATUS'
FROM facility_users u
JOIN facilities f ON f.id = u.facility_id
WHERE f.facility_code = 'FAC-0001'
LIMIT 1;

