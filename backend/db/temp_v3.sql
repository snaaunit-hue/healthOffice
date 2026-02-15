-- V3: ط¬ط¯ظˆظ„ ط±ط¨ط· ط§ظ„ظ…ظˆط¸ظپظٹظ† ط¨ط§ظ„ط£ط¯ظˆط§ط± (admin_roles) ظ„ظ…ط·ط§ط¨ظ‚ط© ط§ظ„ظƒظٹط§ظ† Admin ManyToMany
-- ظ„ط§ ظ†ط­ط°ظپ role_id ظ…ظ† admins ظ„ظ„ط­ظپط§ط¸ ط¹ظ„ظ‰ ط§ظ„طھظˆط§ظپظ‚ ظ…ط¹ ط£ظٹ ط³ظƒط±ط¨طھط§طھ طھط¹طھظ…ط¯ ط¹ظ„ظٹظ‡

CREATE TABLE IF NOT EXISTS admin_roles (
    admin_id         BIGINT NOT NULL REFERENCES admins(id) ON DELETE CASCADE,
    role_id         BIGINT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (admin_id, role_id)
);

-- ظ†ط³ط® ط§ظ„ط±ط¨ط· ط§ظ„ط­ط§ظ„ظٹ (ظƒظ„ ظ…ظˆط¸ظپ ظ„ظ‡ ط¯ظˆط± ظˆط§ط­ط¯ ظ…ظ† role_id) ط¥ظ„ظ‰ admin_roles
INSERT INTO admin_roles (admin_id, role_id)
SELECT id, role_id FROM admins WHERE role_id IS NOT NULL
ON CONFLICT DO NOTHING;

-- ط¬ط¹ظ„ role_id ط§ط®طھظٹط§ط±ظٹط§ظ‹ ظ„ط£ظ† ط§ظ„ط±ط¨ط· ط£طµط¨ط­ ط¹ط¨ط± admin_roles ظپظ‚ط·
ALTER TABLE admins ALTER COLUMN role_id DROP NOT NULL;

COMMENT ON TABLE admin_roles IS 'ط±ط¨ط· ط§ظ„ظ…ظˆط¸ظپظٹظ† (admins) ط¨ط§ظ„ط£ط¯ظˆط§ط± (roles) - طµظ„ط§ط­ظٹط§طھ ط§ظ„ظ…ظˆط¸ظپظٹظ†';

