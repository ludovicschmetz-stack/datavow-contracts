-- =============================================================================
-- DataVow Contracts Demo — PostgreSQL Init
-- 3 schemas: salesforce, sap, odoo
-- Each table has clean rows + intentional violations for demo purposes
-- =============================================================================

-- ============ SALESFORCE SCHEMA ============
CREATE SCHEMA IF NOT EXISTS salesforce;

-- Account
CREATE TABLE salesforce.account (
    id VARCHAR(18),
    name VARCHAR(255),
    type VARCHAR(50),
    industry VARCHAR(100),
    annual_revenue NUMERIC(15,2),
    number_of_employees INTEGER,
    billing_country VARCHAR(10),
    billing_city VARCHAR(100),
    phone VARCHAR(50),
    website VARCHAR(255),
    owner_id VARCHAR(18),
    created_date TIMESTAMP,
    last_modified_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT false
);

INSERT INTO salesforce.account VALUES
-- Clean rows
('001000000000001AAA', 'Acme Corporation',     'Customer', 'Technology',    5000000,  250, 'US', 'San Francisco', '+14155551234', 'https://acme.com',       '005000000000001AAA', '2024-01-15 10:30:00', '2025-03-01 14:22:00', false),
('001000000000002AAA', 'Global Industries',     'Partner',  'Manufacturing', 12000000, 1200,'DE', 'Munich',        '+4989123456',  'https://global-ind.de',  '005000000000002AAA', '2023-06-20 08:00:00', '2025-02-28 09:15:00', false),
('001000000000009AAA', 'Clean Data AG',         'Customer', 'Technology',    4500000,  200, 'CH', 'Zurich',        '+41441234567', 'https://cleandata.ch',   '005000000000009AAA', '2024-02-28 12:00:00', '2025-03-10 08:00:00', false),
('001000000000010AAA', 'Perfect Corp',          'Partner',  'Finance',       9000000,  800, 'LU', 'Luxembourg',    '+35226123456', 'https://perfect.lu',     '005000000000010AAA', '2023-12-01 07:00:00', '2025-03-09 17:00:00', false),
('001000000000011AAA', 'ArcelorMittal SA',      'Customer', 'Steel',         2500000,  500, 'LU', 'Luxembourg',    '+35247921111', 'https://arcelormittal.com','005000000000011AAA','2022-05-10 09:00:00', '2025-01-20 11:00:00', false),
('001000000000012AAA', 'SES Satellites',        'Customer', 'Telecom',       1800000,  350, 'LU', 'Betzdorf',      '+35271071111', 'https://ses.com',        '005000000000012AAA', '2023-03-22 14:00:00', '2025-02-15 10:00:00', false),
-- VIOLATION: empty name (CRITICAL: no_null_account_names)
('001000000000003AAA', '',                      'Customer', 'Finance',       8000000,  500, 'UK', 'London',        '+442071234567','https://noname.co.uk',   '005000000000003AAA', '2024-03-10 11:45:00', '2025-03-05 16:30:00', false),
-- VIOLATION: ID too short — 15 chars (CRITICAL: id_format_18_char)
('00100000004AAA',     'Short ID Corp',         'Prospect', 'Retail',        2000000,  80,  'FR', 'Paris',         '+33140123456', 'https://shortid.fr',     '005000000000004AAA', '2024-07-01 09:00:00', '2025-01-15 10:00:00', false),
-- VIOLATION: negative revenue (WARNING: no_negative_revenue)
('001000000000005AAA', 'Negative Rev Ltd',      'Customer', 'Healthcare',    -500000,  100, 'NL', 'Amsterdam',     '+31201234567', 'https://negrev.nl',      '005000000000005AAA', '2024-09-15 13:00:00', '2025-03-08 11:00:00', false),
-- VIOLATION: future created_date (WARNING: no_future_created_dates)
('001000000000006AAA', 'Future Corp',           'Customer', 'Technology',    3000000,  150, 'US', 'New York',      '+12125551234', 'https://future.com',     '005000000000006AAA', '2027-12-01 10:00:00', '2025-03-01 14:22:00', false),
-- VIOLATION: modified < created (WARNING: modified_after_created)
('001000000000007AAA', 'Time Travel Inc',       'Customer', 'Consulting',    1500000,  45,  'CA', 'Toronto',       '+14165551234', 'https://timetravel.ca',  '005000000000007AAA', '2024-05-10 08:30:00', '2024-01-01 09:00:00', false),
-- VIOLATION: NULL owner_id (CRITICAL: owner_id_not_null)
('001000000000008AAA', 'No Owner Corp',         'Customer', 'Energy',        7000000,  300, 'NO', 'Oslo',          '+4721234567',  'https://noowner.no',     NULL,                  '2024-11-01 10:00:00', '2025-02-20 15:00:00', false);

-- Contact
CREATE TABLE salesforce.contact (
    id VARCHAR(18),
    account_id VARCHAR(18),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(50),
    mailing_country VARCHAR(10),
    title VARCHAR(100),
    department VARCHAR(100),
    lead_source VARCHAR(50),
    owner_id VARCHAR(18),
    created_date TIMESTAMP,
    last_modified_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT false,
    has_opted_out_of_email BOOLEAN DEFAULT false
);

INSERT INTO salesforce.contact VALUES
('003000000000001AAA', '001000000000001AAA', 'John',  'Smith',   'john.smith@acme.com',  '+14155559001', 'US', 'VP Engineering', 'Engineering', 'Web',      '005000000000001AAA', '2024-01-20 10:00:00', '2025-03-01 12:00:00', false, false),
('003000000000002AAA', '001000000000002AAA', 'Maria', 'Schmidt', 'maria@global-ind.de',  '+4989111222',  'DE', 'CTO',            'IT',          'Referral', '005000000000002AAA', '2023-07-01 08:00:00', '2025-02-20 09:00:00', false, false),
('003000000000003AAA', '001000000000010AAA', 'Pierre','Muller',  'pierre@perfect.lu',    '+35226999888', 'LU', 'Data Lead',      'Data',        'Campaign', '005000000000010AAA', '2024-04-15 14:00:00', '2025-03-08 16:00:00', false, false),
-- VIOLATION: empty last_name (CRITICAL: last_name_required)
('003000000000004AAA', '001000000000001AAA', 'Jane',  '',        'jane@acme.com',        '+14155559002', 'US', 'Analyst',        'Analytics',   'Web',      '005000000000001AAA', '2024-08-10 11:00:00', '2025-03-05 10:00:00', false, false),
-- VIOLATION: bad email format (WARNING: email_format_valid)
('003000000000005AAA', '001000000000009AAA', 'Hans',  'Weber',   'not-an-email',         '+41441111222', 'CH', 'Engineer',       'Engineering', 'Partner',  '005000000000009AAA', '2025-01-10 09:00:00', '2025-03-07 11:00:00', false, false),
-- VIOLATION: account_id wrong length (CRITICAL: account_id_format)
('003000000000006AAA', '001000004AAA',       'Luca',  'Rossi',   'luca@short-account.it','+39021234567', 'IT', 'Manager',        'Sales',       'Web',      '005000000000001AAA', '2024-11-20 13:00:00', '2025-02-28 15:00:00', false, false);

-- Opportunity
CREATE TABLE salesforce.opportunity (
    id VARCHAR(18),
    account_id VARCHAR(18),
    name VARCHAR(255),
    stage_name VARCHAR(100),
    amount NUMERIC(15,2),
    probability NUMERIC(5,2),
    close_date DATE,
    type VARCHAR(50),
    lead_source VARCHAR(50),
    is_closed BOOLEAN,
    is_won BOOLEAN,
    forecast_category VARCHAR(50),
    owner_id VARCHAR(18),
    created_date TIMESTAMP,
    last_modified_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT false
);

INSERT INTO salesforce.opportunity VALUES
('006000000000001AAA', '001000000000001AAA', 'Acme - Enterprise Deal',   'Closed Won',   150000, 100,   '2025-02-15', 'New Business',      'Web',      true,  true,  'Closed',    '005000000000001AAA', '2024-06-15 10:00:00', '2025-02-15 16:00:00', false),
('006000000000002AAA', '001000000000002AAA', 'Global - Renewal 2025',    'Negotiation',  85000,  75,    '2025-06-30', 'Renewal',           'Referral', false, false, 'Best Case', '005000000000002AAA', '2025-01-10 09:00:00', '2025-03-01 11:00:00', false),
('006000000000009AAA', '001000000000010AAA', 'Perfect - New Module',     'Proposal',     75000,  65,    '2025-05-31', 'New Business',      'Campaign', false, false, 'Commit',    '005000000000010AAA', '2025-01-05 08:00:00', '2025-03-10 09:00:00', false),
-- VIOLATION: probability > 100 (CRITICAL: probability_range)
('006000000000003AAA', '001000000000009AAA', 'Bad Probability Deal',     'Qualification',30000,  150,   '2025-07-15', 'New Business',      'Web',      false, false, 'Pipeline',  '005000000000009AAA', '2025-01-20 08:00:00', '2025-03-02 12:00:00', false),
-- VIOLATION: is_won=true but is_closed=false (CRITICAL: closed_won_consistency)
('006000000000004AAA', '001000000000005AAA', 'Won But Not Closed',       'Closed Won',   200000, 100,   '2025-03-01', 'New Business',      'Partner',  false, true,  'Closed',    '005000000000005AAA', '2024-11-01 10:00:00', '2025-03-01 09:00:00', false),
-- VIOLATION: negative amount (WARNING: no_negative_amount)
('006000000000005AAA', '001000000000006AAA', 'Negative Deal',            'Prospecting',  -25000, 20,    '2025-09-30', 'New Business',      'Web',      false, false, 'Pipeline',  '005000000000006AAA', '2025-03-01 11:00:00', '2025-03-08 14:00:00', false),
-- VIOLATION: closed-won with amount=0 (WARNING: closed_opps_have_amount)
('006000000000006AAA', '001000000000007AAA', 'Closed Won No Amount',     'Closed Won',   0,      100,   '2025-02-28', 'Existing Business', 'Referral', true,  true,  'Closed',    '005000000000007AAA', '2024-10-15 09:00:00', '2025-02-28 17:00:00', false),
-- VIOLATION: NULL close_date (CRITICAL: close_date_required)
('006000000000007AAA', '001000000000008AAA', 'No Close Date',            'Qualification',20000,  30,    NULL,          'New Business',      'Web',      false, false, 'Pipeline',  '005000000000008AAA', '2025-03-05 14:00:00', '2025-03-09 16:00:00', false);

-- Lead
CREATE TABLE salesforce.lead (
    id VARCHAR(18),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    company VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    status VARCHAR(50),
    lead_source VARCHAR(50),
    industry VARCHAR(100),
    annual_revenue NUMERIC(15,2),
    is_converted BOOLEAN,
    converted_date DATE,
    converted_account_id VARCHAR(18),
    converted_contact_id VARCHAR(18),
    converted_opportunity_id VARCHAR(18),
    owner_id VARCHAR(18),
    created_date TIMESTAMP,
    last_modified_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT false
);

INSERT INTO salesforce.lead VALUES
('00Q000000000001AAA', 'Alice',  'Johnson',  'TechStartup Inc',   'alice@techstartup.io',   '+14155550001', 'Qualified', 'Web',      'Technology',  500000,  false, NULL, NULL, NULL, NULL, '005000000000001AAA', '2025-02-01 10:00:00', '2025-03-01 14:00:00', false),
('00Q000000000002AAA', 'Bob',    'Williams', 'DataCorp',          'bob@datacorp.com',       '+14155550002', 'Converted', 'Referral', 'Technology',  2000000, true,  '2025-02-20', '001000000000001AAA', '003000000000001AAA', '006000000000001AAA', '005000000000001AAA', '2025-01-10 08:00:00', '2025-02-20 16:00:00', false),
-- VIOLATION: empty company (CRITICAL: company_required)
('00Q000000000003AAA', 'Clara',  'Martin',   '',                  'clara@nocompany.com',    '+33140000001', 'New',       'Campaign', 'Finance',     100000,  false, NULL, NULL, NULL, NULL, '005000000000002AAA', '2025-03-05 11:00:00', '2025-03-08 09:00:00', false),
-- VIOLATION: converted=true but no converted_date (WARNING: converted_has_date)
('00Q000000000004AAA', 'David',  'Lee',      'Enterprise Ltd',    'david@enterprise.co.uk', '+442071111222', 'Converted', 'Partner',  'Manufacturing',5000000, true,  NULL, '001000000000002AAA', '003000000000002AAA', NULL, '005000000000002AAA', '2024-11-15 09:00:00', '2025-01-30 10:00:00', false),
-- VIOLATION: bad email format (WARNING: email_format_valid)
('00Q000000000005AAA', 'Emma',   'Dubois',   'French Solutions',  'not-valid-email',        '+33155550003', 'Contacted', 'Web',      'Consulting',  300000,  false, NULL, NULL, NULL, NULL, '005000000000001AAA', '2025-03-08 14:00:00', '2025-03-10 11:00:00', false);


-- ============ SAP SCHEMA ============
CREATE SCHEMA IF NOT EXISTS sap;

-- KNA1 - Customer Master
CREATE TABLE sap.kna1 (
    kunnr VARCHAR(10),
    name1 VARCHAR(100),
    name2 VARCHAR(100),
    land1 VARCHAR(3),
    ort01 VARCHAR(50),
    pstlz VARCHAR(10),
    stras VARCHAR(100),
    telf1 VARCHAR(30),
    smtp_addr VARCHAR(100),
    ktokd VARCHAR(4),
    stcd1 VARCHAR(20),
    erdat DATE,
    ernam VARCHAR(12),
    loevm VARCHAR(1),
    sperr VARCHAR(1)
);

INSERT INTO sap.kna1 VALUES
('0000001000', 'Siemens AG',            'Energy Division',  'DE', 'Munich',       '80333',  'Werner-von-Siemens-Str 1', '+498989001',  'info@siemens.de',    'KUNA', 'DE123456789', '2020-03-15', 'ADMIN01', NULL, NULL),
('0000002000', 'BASF SE',               NULL,               'DE', 'Ludwigshafen', '67056',  'Carl-Bosch-Str 38',        '+496216001',  'contact@basf.com',   'KUNA', 'DE987654321', '2019-07-22', 'ADMIN01', NULL, NULL),
('0000003000', 'Ferrero Luxembourg',     NULL,               'LU', 'Arlon',        'L-8399', 'Zone Industrielle',        '+35226480001','ferrero@ferrero.lu', 'KUNA', 'LU11111111',  '2021-04-10', 'ADMIN02', NULL, NULL),
('0000004000', 'Paul Wurth SA',          NULL,               'LU', 'Luxembourg',   '1122',   'Rue de Neudorf',           '+35226601',   'info@paulwurth.com', 'KUNA', 'LU22222222',  '2020-08-20', 'ADMIN01', NULL, NULL),
-- VIOLATION: empty name1 (CRITICAL: name1_required)
('0000005000', '',                       'Missing Name',     'FR', 'Paris',        '75001',  NULL,                       '+33140000001',NULL,                 'KUNA', NULL,          '2021-01-10', 'ADMIN02', NULL, NULL),
-- VIOLATION: country 3 chars (CRITICAL: country_code_valid)
('0000006000', 'Invalid Country Corp',   NULL,               'XYZ','Berlin',       '10115',  'Friedrichstr 100',         '+493012345',  'bad@country.de',     'KUNA', NULL,          '2023-02-28', 'ADMIN03', NULL, NULL),
-- VIOLATION: empty ktokd (CRITICAL: account_group_not_empty)
('0000007000', 'No Account Group Ltd',   NULL,               'DE', 'Hamburg',      '20095',  'Jungfernstieg 1',          '+494032100',  NULL,                 '',     NULL,          '2021-11-05', 'ADMIN01', NULL, NULL),
-- VIOLATION: future erdat (WARNING: no_future_creation_dates)
('0000008000', 'Future Customer GmbH',   NULL,               'AT', 'Vienna',       '1010',   'Stephansplatz 1',          '+4311234567', 'future@customer.at', 'KUNA', 'AT123456789', '2028-01-01', 'ADMIN01', NULL, NULL),
-- VIOLATION: loevm=X but sperr is empty (INFO: deleted_customers_flagged)
('0000009000', 'Deleted But Active',     NULL,               'CH', 'Zurich',       '8001',   'Bahnhofstr 1',             '+41441234567','deleted@active.ch',  'KUNA', 'CH123456789', '2020-09-15', 'ADMIN02', 'X',  NULL);

-- VBAK - Sales Order Header
CREATE TABLE sap.vbak (
    vbeln VARCHAR(10),
    auart VARCHAR(4),
    vkorg VARCHAR(4),
    vtweg VARCHAR(2),
    spart VARCHAR(2),
    kunnr VARCHAR(10),
    erdat DATE,
    erzet VARCHAR(6),
    ernam VARCHAR(12),
    netwr NUMERIC(15,2),
    waerk VARCHAR(3),
    bstnk VARCHAR(20),
    audat DATE,
    vdatu DATE,
    lifsk VARCHAR(2),
    faksk VARCHAR(2),
    gbstk VARCHAR(1)
);

INSERT INTO sap.vbak VALUES
('0000000001', 'TA', '1000', '10', '00', '0000001000', '2025-01-15', '103000', 'SALES01', 45000.00,  'EUR', 'PO-2025-001', '2025-01-15', '2025-02-15', NULL, NULL, 'A'),
('0000000002', 'TA', '1000', '10', '00', '0000002000', '2025-02-01', '090000', 'SALES02', 120000.00, 'EUR', 'PO-2025-002', '2025-02-01', '2025-03-01', NULL, NULL, 'B'),
('0000000003', 'TA', '2000', '20', '10', '0000003000', '2025-02-20', '140000', 'SALES01', 8500.00,   'EUR', 'PO-2025-003', '2025-02-20', '2025-03-20', NULL, NULL, 'A'),
('0000000004', 'RE', '1000', '10', '00', '0000001000', '2025-03-01', '110000', 'SALES02', -5000.00,  'EUR', 'RET-2025-001','2025-03-01', '2025-03-10', NULL, NULL, 'C'),
-- VIOLATION: empty kunnr (CRITICAL: customer_not_null)
('0000000005', 'TA', '1000', '10', '00', '',           '2025-03-05', '080000', 'SALES01', 30000.00,  'EUR', 'PO-2025-004', '2025-03-05', '2025-04-05', NULL, NULL, 'A'),
-- VIOLATION: currency not 3 chars (CRITICAL: currency_3_char)
('0000000006', 'TA', '1000', '10', '00', '0000002000', '2025-03-08', '150000', 'SALES01', 15000.00,  'EU',  'PO-2025-005', '2025-03-08', '2025-04-08', NULL, NULL, 'A'),
-- VIOLATION: negative netwr on non-return (WARNING: no_negative_net_value)
('0000000007', 'TA', '1000', '10', '00', '0000004000', '2025-03-10', '120000', 'SALES02', -8000.00,  'EUR', 'PO-2025-006', '2025-03-10', '2025-04-10', NULL, NULL, 'A'),
-- VIOLATION: delivery date before creation (INFO: delivery_date_after_creation)
('0000000008', 'TA', '2000', '20', '10', '0000001000', '2025-03-10', '093000', 'SALES01', 22000.00,  'EUR', 'PO-2025-007', '2025-03-10', '2025-01-01', NULL, NULL, 'A');

-- MARA - Material Master
CREATE TABLE sap.mara (
    matnr VARCHAR(40),
    maktx VARCHAR(100),
    mtart VARCHAR(4),
    mbrsh VARCHAR(1),
    matkl VARCHAR(9),
    meins VARCHAR(3),
    brgew NUMERIC(13,3),
    ntgew NUMERIC(13,3),
    gewei VARCHAR(3),
    ersda DATE,
    ernam VARCHAR(12),
    laeda DATE,
    lvorm VARCHAR(1),
    ean11 VARCHAR(18)
);

INSERT INTO sap.mara VALUES
('MAT-001', 'Steel Beam HEB200',    'FERT', 'M', '001', 'KG',  25.500, 25.500, 'KG', '2020-01-10', 'ADMIN01', '2025-01-15', NULL, '4012345678901'),
('MAT-002', 'Copper Wire 2.5mm',    'ROH',  'M', '002', 'KG',  1.200,  1.100,  'KG', '2019-06-15', 'ADMIN01', '2024-11-20', NULL, '4012345678902'),
('MAT-003', 'Hydraulic Pump HP-500', 'FERT', 'M', '003', 'EA',  45.000, 42.000, 'KG', '2021-03-20', 'ADMIN02', '2025-02-28', NULL, '4012345678903'),
('MAT-004', 'Lubricant 5L',         'HAWA', 'C', '004', 'L',   5.800,  5.000,  'KG', '2022-08-10', 'ADMIN01', '2025-03-01', NULL, '4012345678904'),
-- VIOLATION: empty mtart (CRITICAL: material_type_required)
('MAT-005', 'No Type Widget',        '',     'M', '005', 'EA',  0.500,  0.450,  'KG', '2023-05-01', 'ADMIN03', '2025-01-10', NULL, '4012345678905'),
-- VIOLATION: empty meins (CRITICAL: base_uom_required)
('MAT-006', 'No UOM Product',        'FERT', 'M', '006', '',    2.000,  1.800,  'KG', '2024-01-15', 'ADMIN01', '2025-02-15', NULL, '4012345678906'),
-- VIOLATION: empty description (WARNING: description_present)
('MAT-007', '',                       'ROH',  'M', '007', 'KG',  10.000, 9.500,  'KG', '2024-07-20', 'ADMIN02', '2025-03-05', NULL, '4012345678907'),
-- VIOLATION: net weight > gross weight (WARNING: weight_consistency)
('MAT-008', 'Heavy Net Bolt',         'FERT', 'M', '008', 'EA',  0.100,  0.500,  'KG', '2024-09-01', 'ADMIN01', '2025-03-08', NULL, '4012345678908');


-- ============ ODOO SCHEMA ============
CREATE SCHEMA IF NOT EXISTS odoo;

-- res.partner
CREATE TABLE odoo.res_partner (
    id INTEGER,
    name VARCHAR(255),
    is_company BOOLEAN,
    parent_id INTEGER,
    email VARCHAR(255),
    phone VARCHAR(50),
    mobile VARCHAR(50),
    street VARCHAR(255),
    city VARCHAR(100),
    zip VARCHAR(20),
    country_id INTEGER,
    vat VARCHAR(30),
    customer_rank INTEGER DEFAULT 0,
    supplier_rank INTEGER DEFAULT 0,
    active BOOLEAN DEFAULT true,
    create_date TIMESTAMP,
    write_date TIMESTAMP
);

INSERT INTO odoo.res_partner VALUES
(10, 'Post Luxembourg',       true,  NULL, 'info@post.lu',       '+35224761',    NULL, '25 Rue Emile Bian',     'Luxembourg', '1235', 126, 'LU11111111', 1, 0, true, '2023-01-15 10:00:00', '2025-03-01 14:00:00'),
(11, 'Jean Schmit',           false, 10,   'jean@post.lu',       '+35224761001', NULL, NULL,                     'Luxembourg', '1235', 126, NULL,         1, 0, true, '2023-06-20 08:00:00', '2025-02-28 09:00:00'),
(12, 'Cactus SA',             true,  NULL, 'contact@cactus.lu',  '+35226311',    NULL, 'Route de Longwy',        'Bereldange', '7260', 126, 'LU22222222', 1, 1, true, '2023-09-10 11:00:00', '2025-03-05 16:00:00'),
(13, 'Luxair Group',          true,  NULL, 'info@luxair.lu',     '+35224981',    NULL, 'Aeroport de Luxembourg', 'Findel',     '1110', 126, 'LU33333333', 1, 0, true, '2022-04-18 09:00:00', '2025-01-20 15:00:00'),
-- VIOLATION: empty name (CRITICAL: name_required)
(14, '',                      true,  NULL, 'contact@noname.com', '+352261111',   NULL, '5 Av Monterey',          'Luxembourg', '2163', 126, 'LU87654321', 1, 0, true, '2024-03-10 11:00:00', '2025-03-05 16:00:00'),
-- VIOLATION: orphan contact — parent_id=9999 doesn't exist (CRITICAL: no_orphan_contacts)
(15, 'Orphan Contact',        false, 9999, 'orphan@nowhere.com', '+352621111',   NULL, NULL,                     'Esch',       '4001', 126, NULL,         1, 0, true, '2024-07-01 09:00:00', '2025-01-15 10:00:00'),
-- VIOLATION: bad email format (WARNING: email_format_valid)
(16, 'Bad Email SARL',        true,  NULL, 'bad-email-format',   '+352261222',   NULL, '8 Bd Royal',             'Luxembourg', '2449', 126, NULL,         1, 0, true, '2024-09-15 13:00:00', '2025-03-08 11:00:00'),
-- VIOLATION: B2B customer without VAT (INFO: company_has_vat)
(17, 'No VAT Customer SARL',  true,  NULL, 'novat@customer.lu',  '+352261333',   NULL, '12 Rue du Fort',         'Luxembourg', '1616', 126, NULL,         1, 0, true, '2025-01-10 08:00:00', '2025-03-02 12:00:00');

-- sale.order
CREATE TABLE odoo.sale_order (
    id INTEGER,
    name VARCHAR(20),
    partner_id INTEGER,
    state VARCHAR(20),
    date_order TIMESTAMP,
    amount_untaxed NUMERIC(15,2),
    amount_tax NUMERIC(15,2),
    amount_total NUMERIC(15,2),
    currency_id INTEGER,
    pricelist_id INTEGER,
    user_id INTEGER,
    team_id INTEGER,
    invoice_status VARCHAR(20),
    commitment_date TIMESTAMP,
    create_date TIMESTAMP,
    write_date TIMESTAMP
);

INSERT INTO odoo.sale_order VALUES
(1, 'S00001', 10, 'sale',   '2025-01-15 10:00:00', 1000.00, 170.00, 1170.00, 1, 1, 5, 1, 'invoiced',   NULL, '2025-01-15 10:00:00', '2025-02-01 14:00:00'),
(2, 'S00002', 12, 'sale',   '2025-02-01 09:00:00', 500.00,  85.00,  585.00,  1, 1, 5, 1, 'to invoice', NULL, '2025-02-01 09:00:00', '2025-03-01 11:00:00'),
(3, 'S00003', 13, 'done',   '2025-01-10 08:00:00', 3000.00, 510.00, 3510.00, 1, 1, 6, 2, 'invoiced',   NULL, '2025-01-10 08:00:00', '2025-02-15 17:00:00'),
(4, 'S00004', 10, 'draft',  '2025-03-10 09:00:00', 1200.00, 204.00, 1404.00, 1, 1, 5, 1, 'no',         NULL, '2025-03-10 09:00:00', '2025-03-10 09:00:00'),
-- VIOLATION: amount_total != untaxed + tax (CRITICAL: amount_total_consistency)
(5, 'S00005', 12, 'sale',   '2025-02-15 14:00:00', 800.00,  136.00, 1050.00, 1, 1, 6, 2, 'to invoice', NULL, '2025-02-15 14:00:00', '2025-03-05 10:00:00'),
-- VIOLATION: NULL partner_id (CRITICAL: partner_required)
(6, 'S00006', NULL,'draft',  '2025-03-01 08:00:00', 300.00,  51.00,  351.00,  1, 1, 5, 1, 'no',         NULL, '2025-03-01 08:00:00', '2025-03-01 08:00:00'),
-- VIOLATION: invalid state (CRITICAL: valid_state)
(7, 'S00007', 13, 'invalid_state', '2025-03-05 11:00:00', 2000.00, 340.00, 2340.00, 1, 1, 6, 1, 'to invoice', NULL, '2025-03-05 11:00:00', '2025-03-08 09:00:00'),
-- VIOLATION: cancelled but invoiced (WARNING: cancelled_not_invoiced)
(8, 'S00008', 10, 'cancel', '2025-02-20 10:00:00', 750.00,  127.50, 877.50,  1, 1, 5, 2, 'invoiced',   NULL, '2025-02-20 10:00:00', '2025-03-02 16:00:00'),
-- VIOLATION: state=sale but date_order is NULL (CRITICAL: confirmed_orders_have_date)
(9, 'S00009', 12, 'sale',   NULL,                   1500.00, 255.00, 1755.00, 1, 1, 6, 1, 'to invoice', NULL, '2025-03-01 09:00:00', '2025-03-07 14:00:00');

-- product.product
CREATE TABLE odoo.product_product (
    id INTEGER,
    product_tmpl_id INTEGER,
    name VARCHAR(255),
    default_code VARCHAR(50),
    barcode VARCHAR(20),
    type VARCHAR(10),
    categ_id INTEGER,
    list_price NUMERIC(15,2),
    standard_price NUMERIC(15,2),
    uom_id INTEGER,
    weight NUMERIC(10,3),
    sale_ok BOOLEAN,
    purchase_ok BOOLEAN,
    active BOOLEAN DEFAULT true,
    create_date TIMESTAMP,
    write_date TIMESTAMP
);

INSERT INTO odoo.product_product VALUES
(1, 1, 'Office Desk Standard',    'DESK-001', '5901234567890', 'product', 1, 299.00, 180.00, 1, 25.000, true,  true,  true, '2023-01-10 10:00:00', '2025-01-15 12:00:00'),
(2, 2, 'Ergonomic Chair Pro',     'CHAIR-001','5901234567891', 'product', 1, 449.00, 250.00, 1, 15.000, true,  true,  true, '2023-03-20 09:00:00', '2025-02-20 11:00:00'),
(3, 3, 'IT Support - Hourly',     'SVC-001',  NULL,            'service', 2, 120.00, 80.00,  2, NULL,   true,  false, true, '2023-06-15 14:00:00', '2025-03-01 10:00:00'),
(4, 4, 'Printer Paper A4 (500)',  'PAPER-001','5901234567892', 'consu',   3, 5.99,   3.50,   1, 2.500,  true,  true,  true, '2024-01-08 08:00:00', '2025-02-15 09:00:00'),
-- VIOLATION: invalid type (CRITICAL: valid_type)
(5, 5, 'Mystery Widget',          'WID-001',  '5901234567893', 'magical', 1, 49.99,  30.00,  1, 0.500,  true,  true,  true, '2024-05-20 11:00:00', '2025-03-05 14:00:00'),
-- VIOLATION: sellable with price <= 0 (WARNING: positive_sale_price)
(6, 6, 'Free Giveaway Pen',       'PEN-001',  '5901234567894', 'consu',   3, 0.00,   0.50,   1, 0.020,  true,  true,  true, '2024-08-10 10:00:00', '2025-03-08 09:00:00'),
-- VIOLATION: cost > 2x sale price (INFO: cost_not_exceeds_sale)
(7, 7, 'Mispriced Cable',         'CABLE-001','5901234567895', 'product', 1, 9.99,   25.00,  1, 0.150,  true,  true,  true, '2024-11-01 13:00:00', '2025-03-07 16:00:00'),
-- VIOLATION: duplicate barcode (CRITICAL: barcode_unique_when_set)
(8, 8, 'Duplicate Barcode Item',  'DUP-001',  '5901234567890', 'product', 1, 19.99,  12.00,  1, 1.000,  true,  true,  true, '2025-01-15 09:00:00', '2025-03-09 11:00:00'),
-- VIOLATION: negative weight (WARNING: no_negative_weight)
(9, 9, 'Negative Weight Thing',   'NEG-001',  '5901234567896', 'product', 1, 29.99,  15.00,  1, -0.500, true,  true,  true, '2025-02-20 10:00:00', '2025-03-10 08:00:00');

-- Grant access
GRANT USAGE ON SCHEMA salesforce TO datavow;
GRANT USAGE ON SCHEMA sap TO datavow;
GRANT USAGE ON SCHEMA odoo TO datavow;
GRANT SELECT ON ALL TABLES IN SCHEMA salesforce TO datavow;
GRANT SELECT ON ALL TABLES IN SCHEMA sap TO datavow;
GRANT SELECT ON ALL TABLES IN SCHEMA odoo TO datavow;
