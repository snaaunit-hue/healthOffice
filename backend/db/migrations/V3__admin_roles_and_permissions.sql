-- V3: جدول ربط الموظفين بالأدوار (admin_roles) لمطابقة الكيان Admin ManyToMany
-- لا نحذف role_id من admins للحفاظ على التوافق مع أي سكربتات تعتمد عليه

CREATE TABLE IF NOT EXISTS admin_roles (
    admin_id         BIGINT NOT NULL REFERENCES admins(id) ON DELETE CASCADE,
    role_id         BIGINT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (admin_id, role_id)
);

-- نسخ الربط من role_id إلى admin_roles (فقط إن وُجد عمود role_id في admins)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'admins' AND column_name = 'role_id'
  ) THEN
    INSERT INTO admin_roles (admin_id, role_id)
    SELECT id, role_id FROM admins WHERE role_id IS NOT NULL
    ON CONFLICT DO NOTHING;
    ALTER TABLE admins ALTER COLUMN role_id DROP NOT NULL;
  END IF;
END $$;

COMMENT ON TABLE admin_roles IS 'ربط الموظفين (admins) بالأدوار (roles) - صلاحيات الموظفين';
