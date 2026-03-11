<div align="center">

# datavow-contracts

**Ready-to-use data contracts for ERP, CRM, and SaaS platforms.**

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![DataVow](https://img.shields.io/badge/powered%20by-DataVow-1a365d.svg)](https://datavow.io)
[![ODCS](https://img.shields.io/badge/ODCS-v3.1%20compatible-38a169.svg)](https://bitol.io/open-data-contract-standard/)

</div>

---

## What is this?

A community-maintained library of [DataVow](https://github.com/ludovicschmetz-stack/datavow) contracts for common enterprise systems. Each contract defines the expected schema, quality rules, and SLA for a specific table or object — ready to validate your data warehouse extracts.

**Use these contracts as-is or fork them as a starting point for your own.**

## Contracts

### Odoo ERP

| Object | Domain | Contract | Key Rules |
|---|---|---|---|
| `product.product` | products | [`odoo/product.yaml`](odoo/product.yaml) | Positive prices, valid types, barcode uniqueness, weight checks |
| `res.partner` | contacts | [`odoo/res-partner.yaml`](odoo/res-partner.yaml) | Email format, VAT on companies, contact hierarchy |
| `sale.order` | sales | [`odoo/sale-order.yaml`](odoo/sale-order.yaml) | Amount consistency, state validation, partner required |

### SAP ERP

| Table | Domain | Contract | Key Rules |
|---|---|---|---|
| `KNA1` (Customers) | master-data | [`sap-erp/kna1-customers.yaml`](sap-erp/kna1-customers.yaml) | KUNNR format, country codes, account group, deletion flags |
| `MARA` (Materials) | master-data | [`sap-erp/mara-materials.yaml`](sap-erp/mara-materials.yaml) | Material number, UoM required, weight consistency |
| `VBAK` (Sales Orders) | sales | [`sap-erp/vbak-sales-orders.yaml`](sap-erp/vbak-sales-orders.yaml) | VBELN format, customer not null, net value, currency |

### Salesforce CRM

| Object | Domain | Contract | Key Rules |
|---|---|---|---|
| `Account` | crm | [`salesforce/account.yaml`](salesforce/account.yaml) | ID format (18 char), owner required, revenue checks, modified > created |
| `Contact` | crm | [`salesforce/contact.yaml`](salesforce/contact.yaml) | Account ID format, email format, last name required |
| `Lead` | crm | [`salesforce/lead.yaml`](salesforce/lead.yaml) | Company required, conversion consistency, email format |
| `Opportunity` | crm | [`salesforce/opportunity.yaml`](salesforce/opportunity.yaml) | Won deals have amount, probability range, stage/flag consistency |

## Quick start

```bash
# Install DataVow
pip install datavow

# Clone this repo
git clone https://github.com/ludovicschmetz-stack/datavow-contracts.git
cd datavow-contracts

# Validate your data against a contract
datavow validate salesforce/account.yaml data/salesforce_account.csv --verbose

# Generate a stakeholder report
datavow report odoo/sale-order.yaml data/odoo_sale_order.csv
```

## Try the demo

The repo includes a Docker-based demo with PostgreSQL, intentionally dirty sample data, and a full dbt project.

```bash
# Start PostgreSQL + load sample data
docker compose up -d

# Validate all contracts
datavow validate odoo/product.yaml data/odoo_product_product.csv --verbose
datavow validate sap-erp/vbak-sales-orders.yaml data/sap_vbak.csv --verbose
datavow validate salesforce/account.yaml data/salesforce_account.csv --verbose

# Or use the demo script
./run-demo.sh
```

### With dbt

The `dbt/` directory contains a complete dbt project with staging models and DataVow-generated tests for all 10 contracts.

```bash
cd dbt
dbt deps
dbt run
dbt test    # Runs all DataVow-generated tests
```

## Structure

```
datavow-contracts/
├── odoo/                     # Odoo ERP contracts
│   ├── product.yaml
│   ├── res-partner.yaml
│   └── sale-order.yaml
├── sap-erp/                  # SAP ERP contracts
│   ├── kna1-customers.yaml
│   ├── mara-materials.yaml
│   └── vbak-sales-orders.yaml
├── salesforce/               # Salesforce CRM contracts
│   ├── account.yaml
│   ├── contact.yaml
│   ├── lead.yaml
│   └── opportunity.yaml
├── data/                     # Sample CSVs (intentionally dirty)
├── dbt/                      # dbt project with staging models + tests
├── docker/                   # PostgreSQL init script
├── docker-compose.yml        # Demo environment
├── reports/                  # Sample HTML reports
└── run-demo.sh               # One-command demo
```

## Customization

These contracts cover standard fields. Your systems likely have custom fields — add them:

```yaml
# Odoo custom field
- name: x_approval_workflow
  type: string
  required: false

# SAP Z-field
- name: ZZPROJECT_CODE
  type: string
  required: false

# Salesforce custom field
- name: Custom_Score__c
  type: decimal
  required: false
  min: 0
  max: 100
```

## Contributing

Contributions welcome. To add contracts for a new system:

1. Create a directory named after the system (lowercase)
2. Add one `.yaml` contract per table/object
3. Include sample data in `data/` if possible
4. Open a PR

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## Related

- [DataVow CLI](https://github.com/ludovicschmetz-stack/datavow) — the validation engine
- [DataVow GitHub Action](https://github.com/ludovicschmetz-stack/datavow-action) — CI/CD integration
- [DataVow dbt package](https://github.com/ludovicschmetz-stack/datavow-dbt) — dbt on-run-end hook
- [ODCS v3.1](https://bitol.io/open-data-contract-standard/) — the standard behind DataVow

## License

Apache 2.0 — see [LICENSE](LICENSE).
