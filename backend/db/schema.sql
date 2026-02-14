-- PostgreSQL schema for Health and Environment Office – Capital Secretariat, Sana’a
-- Core master tables

CREATE TABLE roles (
    id              BIGSERIAL PRIMARY KEY,
    code            VARCHAR(50) UNIQUE NOT NULL,
    name_ar         VARCHAR(255) NOT NULL,
    name_en         VARCHAR(255) NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE permissions (
    id              BIGSERIAL PRIMARY KEY,
    code            VARCHAR(100) UNIQUE NOT NULL,
    description_ar  VARCHAR(255),
    description_en  VARCHAR(255)
);

CREATE TABLE role_permissions (
    role_id         BIGINT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id   BIGINT NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE facilities (
    id                  BIGSERIAL PRIMARY KEY,
    facility_code       VARCHAR(50) UNIQUE NOT NULL,
    name_ar             VARCHAR(255) NOT NULL,
    name_en             VARCHAR(255),
    facility_type       VARCHAR(50) NOT NULL, -- hospital, center, clinic, pharmacy, etc.
    license_type        VARCHAR(20) NOT NULL, -- NEW, RENEWAL, etc.
    district            VARCHAR(150),
    area                VARCHAR(150),
    street              VARCHAR(150),
    property_owner      VARCHAR(255),
    ownership_proof_url TEXT,
    site_sketch_url     TEXT,
    rooms_count         INT CHECK (rooms_count >= 0),
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE admins (
    id              BIGSERIAL PRIMARY KEY,
    full_name       VARCHAR(255) NOT NULL,
    username        VARCHAR(100) UNIQUE NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,
    phone_number    VARCHAR(30),
    email           VARCHAR(150),
    role_id         BIGINT NOT NULL REFERENCES roles(id),
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login_at   TIMESTAMPTZ
);

CREATE TABLE facility_users (
    id              BIGSERIAL PRIMARY KEY,
    facility_id     BIGINT NOT NULL REFERENCES facilities(id) ON DELETE CASCADE,
    full_name       VARCHAR(255) NOT NULL,
    phone_number    VARCHAR(30) NOT NULL,
    email           VARCHAR(150),
    national_id     VARCHAR(50),
    user_type       VARCHAR(30) NOT NULL, -- OWNER, DELEGATE
    password_hash   VARCHAR(255) NOT NULL,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    last_login_at   TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Applications & workflow

CREATE TABLE applications (
    id                      BIGSERIAL PRIMARY KEY,
    application_number      VARCHAR(50) UNIQUE NOT NULL,
    facility_id             BIGINT NOT NULL REFERENCES facilities(id),
    submitted_by_user_id    BIGINT REFERENCES facility_users(id),
    status                  VARCHAR(30) NOT NULL, -- DRAFT, SUBMITTED, UNDER_REVIEW, INSPECTION_SCHEDULED, ...
    license_type            VARCHAR(20) NOT NULL, -- NEW, RENEWAL
    facility_type           VARCHAR(50) NOT NULL,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    submitted_at            TIMESTAMPTZ,
    approved_at             TIMESTAMPTZ,
    rejected_at             TIMESTAMPTZ,
    rejection_reason        TEXT
);

CREATE TABLE application_steps (
    id                  BIGSERIAL PRIMARY KEY,
    application_id      BIGINT NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
    step_order          INT NOT NULL,
    step_code           VARCHAR(50) NOT NULL, -- DRAFT, SUBMIT, LICENSING_REVIEW, INSPECTION_SCHEDULING, ...
    status              VARCHAR(30) NOT NULL, -- PENDING, IN_PROGRESS, COMPLETED, REJECTED
    performed_by_admin  BIGINT REFERENCES admins(id),
    performed_by_user   BIGINT REFERENCES facility_users(id),
    performed_at        TIMESTAMPTZ,
    notes               TEXT
);

CREATE TABLE application_documents (
    id                  BIGSERIAL PRIMARY KEY,
    application_id      BIGINT NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
    document_type       VARCHAR(100) NOT NULL,
    reference_number    VARCHAR(100),
    issue_date          DATE,
    is_mandatory        BOOLEAN NOT NULL DEFAULT TRUE,
    file_url            TEXT NOT NULL,
    uploaded_by_user    BIGINT REFERENCES facility_users(id),
    uploaded_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Inspections & violations

CREATE TABLE inspections (
    id                  BIGSERIAL PRIMARY KEY,
    application_id      BIGINT NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
    scheduled_date      TIMESTAMPTZ,
    actual_visit_date   TIMESTAMPTZ,
    inspector_id        BIGINT REFERENCES admins(id),
    status              VARCHAR(30) NOT NULL, -- SCHEDULED, COMPLETED, CANCELLED
    overall_score       NUMERIC(5,2),
    notes               TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE inspection_scores (
    id                  BIGSERIAL PRIMARY KEY,
    inspection_id       BIGINT NOT NULL REFERENCES inspections(id) ON DELETE CASCADE,
    criterion_code      VARCHAR(100) NOT NULL,
    description         TEXT,
    score               NUMERIC(5,2) NOT NULL,
    max_score           NUMERIC(5,2) NOT NULL
);

CREATE TABLE violations (
    id                  BIGSERIAL PRIMARY KEY,
    inspection_id       BIGINT REFERENCES inspections(id) ON DELETE SET NULL,
    application_id      BIGINT REFERENCES applications(id) ON DELETE SET NULL,
    code                VARCHAR(50) NOT NULL,
    description         TEXT NOT NULL,
    penalty             TEXT,
    severity            VARCHAR(20), -- MINOR, MAJOR, CRITICAL
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    suspension_applied  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at         TIMESTAMPTZ
);

-- Payments & licenses

CREATE TABLE payments (
    id                      BIGSERIAL PRIMARY KEY,
    application_id          BIGINT NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
    payment_reference       VARCHAR(100) UNIQUE NOT NULL,
    governorate_code        VARCHAR(50) NOT NULL,
    amount                  NUMERIC(12,2) NOT NULL,
    status                  VARCHAR(30) NOT NULL, -- PENDING, PAID, FAILED, CANCELLED
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    paid_at                 TIMESTAMPTZ,
    external_transaction_id VARCHAR(150),
    payment_channel         VARCHAR(50), -- BANK, WALLET, GATEWAY, etc.
    notes                   TEXT
);

CREATE TABLE licenses (
    id                      BIGSERIAL PRIMARY KEY,
    application_id          BIGINT NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
    license_number          VARCHAR(100) UNIQUE NOT NULL,
    issue_date              DATE NOT NULL,
    expiry_date             DATE NOT NULL,
    pdf_url                 TEXT NOT NULL,
    status                  VARCHAR(30) NOT NULL, -- ACTIVE, SUSPENDED, EXPIRED, REVOKED
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Notifications & settings

CREATE TABLE notifications (
    id                  BIGSERIAL PRIMARY KEY,
    recipient_admin_id  BIGINT REFERENCES admins(id),
    recipient_user_id   BIGINT REFERENCES facility_users(id),
    title_ar            VARCHAR(255),
    title_en            VARCHAR(255),
    body_ar             TEXT,
    body_en             TEXT,
    type                VARCHAR(50),
    read                BOOLEAN NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    read_at             TIMESTAMPTZ
);

CREATE TABLE system_settings (
    id              BIGSERIAL PRIMARY KEY,
    category        VARCHAR(100) NOT NULL,
    key             VARCHAR(100) NOT NULL,
    value           VARCHAR(255) NOT NULL,
    description     TEXT,
    UNIQUE (category, key)
);

CREATE TABLE audit_logs (
    id              BIGSERIAL PRIMARY KEY,
    event_time      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    actor_admin_id  BIGINT REFERENCES admins(id),
    actor_user_id   BIGINT REFERENCES facility_users(id),
    actor_ip        VARCHAR(50),
    action          VARCHAR(100) NOT NULL,
    entity_type     VARCHAR(100),
    entity_id       BIGINT,
    details         TEXT
);

