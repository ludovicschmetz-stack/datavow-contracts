# datavow-contracts

Ready-to-use data contracts for common systems integrated into data warehouses.

## What is this?

A community library of [DataVow](https://github.com/ludovicschmetz-stack/datavow) data contracts for popular CRM, ERP, and SaaS platforms. Copy a contract, adapt it to your schema, and validate your data in minutes.

Every contract includes:
- **Schema definition** with field types, descriptions, and PII flags
- **Quality rules** based on real business logic (not toy examples)
- **SLA expectations** for freshness and completeness

## Contracts

### Salesforce

| Contract | Object | Domain | Rules |
|---|---|---|---|
| [`salesforce/account.yaml`](salesforce/account.yaml) | Account | sales | 6 rules — ID format, required fields, revenue checks |
| [`salesforce/contact.yaml`](salesforce/contact.yaml) | Contact | sales | 5 rules — PII flagged, email format, FK consistency |
| [`salesforce/opportunity.yaml`](salesforce/opportunity.yaml) | Opportunity | sales | 7 rules — pipeline integrity, win/close consistency |
| [`salesforce/lead.yaml`](salesforce/lead.yaml) | Lead | marketing | 7 rules — conversion checks, email format |

### SAP ERP

| Contract | Table | Domain | Rules |
|---|---|---|---|
| [`sap-erp/kna1-customers.yaml`](sap-erp/kna1-customers.yaml) | KNA1 | master-data | 6 rules — customer number format, country code, deletion flags |
| [`sap-erp/vbak-sales-orders.yaml`](sap-erp/vbak-sales-orders.yaml) | VBAK | sales | 6 rules — currency format, negative value checks, date logic |
| [`sap-erp/mara-materials.yaml`](sap-erp/mara-materials.yaml) | MARA | master-data | 6 rules — material type, UoM, weight consistency |

### Odoo

| Contract | Model | Domain | Rules |
|---|---|---|---|
| [`odoo/res-partner.yaml`](odoo/res-partner.yaml) | res.partner | master-data | 5 rules — orphan contacts, VAT checks, email format |
| [`odoo/sale-order.yaml`](odoo/sale-order.yaml) | sale.order | sales | 6 rules — state validation, amount consistency, invoice status |
| [`odoo/product.yaml`](odoo/product.yaml) | product.product | master-data | 6 rules — barcode uniqueness, price checks, product type |

## Usage

```bash
# Install DataVow
pip install datavow

# Copy a contract and adapt to your schema
cp salesforce/account.yaml contracts/

# Validate against your data
datavow validate contracts/account.yaml --source data/accounts.csv

# Sync to dbt tests
datavow dbt sync contracts/ --dbt-project-dir .
```

## Customization

These contracts cover **standard fields** — your instance likely has custom fields. Adapt them:

1. Copy the contract to your project
2. Add/remove fields to match your extraction schema
3. Adjust quality rules to your business context
4. Set appropriate SLA thresholds

Column names may differ depending on your ETL tool (Fivetran, Airbyte, Stitch all name columns differently). Adjust the `name` fields accordingly.

## Contributing

Have a contract for a system not listed here? PRs welcome.

Guidelines:
- One YAML file per object/table
- Include realistic quality rules (not just null checks)
- Add `description` to non-obvious fields
- Flag PII fields with `pii: true`
- Test with `datavow validate` before submitting

## License

Apache 2.0 — same as [DataVow](https://github.com/ludovicschmetz-stack/datavow).
