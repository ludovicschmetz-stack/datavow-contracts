# Contributing to datavow-contracts

Thanks for contributing! This repo is a community-maintained library of data contracts.

## Adding contracts for a new system

1. **Create a directory** named after the system (lowercase, e.g. `hubspot/`, `stripe/`, `snowflake/`)
2. **One contract per table/object** — name the file after the table (e.g. `contacts.yaml`, `invoices.yaml`)
3. **Follow the DataVow contract format** — see existing contracts for reference
4. **Add a README.md** in your directory with:
   - Brief description of the system
   - Table of contracts with key rules
   - Typical extraction methods
   - Usage examples
   - Customization hints
5. **Add sample data** (optional but encouraged) in `docker/data/` with intentionally dirty rows to demonstrate validation
6. **Test your contracts** — run `datavow validate` against your sample data

## Contract quality checklist

- [ ] All required fields have `required: true`
- [ ] PII fields are flagged with `pii: true`
- [ ] At least 3 quality rules per contract
- [ ] At least 1 CRITICAL rule (data integrity)
- [ ] At least 1 WARNING rule (business logic)
- [ ] SLA section with freshness and completeness
- [ ] Field descriptions for non-obvious fields
- [ ] `metadata.domain` is set (Data Mesh ready)

## Style guide

- Use the system's native field names in the raw/bronze layer (e.g. SAP's `VBELN`, not `sales_order_number`)
- Keep descriptions concise — one line max
- Use ISO formats (dates, currencies, country codes)
- Severity assignment: CRITICAL = data integrity, WARNING = business logic, INFO = monitoring

## Opening a PR

1. Fork the repo
2. Create a branch (`feat/hubspot-contacts`)
3. Add your contracts + README
4. Open a PR with a brief description of the system and tables covered

We review PRs within a week.
