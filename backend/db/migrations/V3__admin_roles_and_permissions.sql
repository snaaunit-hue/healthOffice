-- V3: جدول ربط الموظفين بالأدوار (admin_roles) لمطابقة الكيان Admin ManyToMany
-- لا نحذف role_id من admins للحفاظ على التوافق مع أي سكربتات تعتمد عليه

CREATE TABLE IF NOT EXISTS admin_roles (
    admin_id         BIGINT NOT NULL REFERENCES admins(id) ON DELETE CASCADE,
    role_id         BIGINT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (admin_id, role_id)
);

-- نسخ الربط الحالي (كل موظف له دور واحد من role_id) إلى admin_roles
INSERT INTO admin_roles (admin_id, role_id)
SELECT id, role_id FROM admins WHERE role_id IS NOT NULL
ON CONFLICT DO NOTHING;

-- جعل role_id اختيارياً لأن الربط أصبح عبر admin_roles فقط
ALTER TABLE admins ALTER COLUMN role_id DROP NOT NULL;

COMMENT ON TABLE admin_roles IS 'ربط الموظفين (admins) بالأدوار (roles) - صلاحيات الموظفين';
