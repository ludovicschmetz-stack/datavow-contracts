#!/bin/bash
# =============================================================================
# DataVow Contracts Demo — Full Cycle
#
# Demonstrates: PostgreSQL + 3 schemas (Salesforce, SAP, Odoo)
#   → datavow validate (CSV export from DB)
#   → datavow dbt sync (generate dbt tests from contracts)
#   → dbt run + dbt test (execute generated tests)
#   → datavow dbt validate (direct warehouse connection)
#
# Prerequisites: Docker Desktop, datavow (pip install datavow), dbt-postgres
# =============================================================================

set -euo pipefail

DEMO_DIR="$(cd "$(dirname "$0")" && pwd)"
DBT_DIR="$DEMO_DIR/dbt"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

header() { echo ""; echo -e "${BLUE}═══════════════════════════════════════════${NC}"; echo -e "${BLUE}  $1${NC}"; echo -e "${BLUE}═══════════════════════════════════════════${NC}"; }
step()   { echo -e "\n${GREEN}▸ $1${NC}"; }
warn()   { echo -e "${YELLOW}  ⚠ $1${NC}"; }
info()   { echo -e "  $1"; }

# ─── Find working datavow binary ─────────────────────────────────────────────
DATAVOW=""
for candidate in datavow /opt/homebrew/bin/datavow; do
    if $candidate --version &>/dev/null 2>&1; then
        DATAVOW="$candidate"
        break
    fi
done
if [ -z "$DATAVOW" ]; then
    echo -e "${RED}  ✗ datavow not found or broken. Run: pip install datavow${NC}"
    exit 1
fi

# ─────────────────────────────────────────────────────────────────────────────
header "DataVow Contracts Demo"
info "3 systems × 10 contracts × 60 quality rules"
info "Source: PostgreSQL (Salesforce + SAP ERP + Odoo)"
info "Using: $($DATAVOW --version)"
# ─────────────────────────────────────────────────────────────────────────────

# ── Step 1: Check prerequisites ──────────────────────────────────────────────
step "Checking prerequisites..."
info "✓ $($DATAVOW --version)"

HAS_DBT=false
if command -v dbt &>/dev/null; then
    info "✓ dbt installed"
    HAS_DBT=true
else
    warn "dbt not found — dbt steps will be skipped"
    warn "Install with: pip install dbt-postgres"
fi

if ! command -v docker &>/dev/null; then
    echo -e "${RED}  ✗ docker not found. Install Docker Desktop.${NC}"
    exit 1
fi
info "✓ docker"

# ── Step 2: Start PostgreSQL ─────────────────────────────────────────────────
step "Starting PostgreSQL (port 5433)..."

cd "$DEMO_DIR"
docker compose down --remove-orphans 2>/dev/null || true
docker compose up -d 2>&1 | grep -v "obsolete" || true

info "Waiting for database..."
for i in $(seq 1 30); do
    if docker compose exec -T postgres pg_isready -U datavow -d datavow_demo &>/dev/null; then
        break
    fi
    sleep 1
    printf "."
done
echo ""

# Verify
info "Data loaded:"
for schema_table in salesforce.account salesforce.contact salesforce.opportunity salesforce.lead sap.kna1 sap.vbak sap.mara odoo.res_partner odoo.sale_order odoo.product_product; do
    count=$(docker compose exec -T postgres psql -U datavow -d datavow_demo -t -c "SELECT COUNT(*) FROM $schema_table" 2>/dev/null | tr -d ' ')
    printf "  %-35s %s rows\n" "$schema_table" "$count"
done

# ── Step 3: Export to CSV ────────────────────────────────────────────────────
header "Step 3: Export tables to CSV"

mkdir -p "$DEMO_DIR/data"

TABLES=(
    "salesforce.account:salesforce_account"
    "salesforce.contact:salesforce_contact"
    "salesforce.opportunity:salesforce_opportunity"
    "salesforce.lead:salesforce_lead"
    "sap.kna1:sap_kna1"
    "sap.vbak:sap_vbak"
    "sap.mara:sap_mara"
    "odoo.res_partner:odoo_res_partner"
    "odoo.sale_order:odoo_sale_order"
    "odoo.product_product:odoo_product_product"
)

for entry in "${TABLES[@]}"; do
    schema_table="${entry%%:*}"
    filename="${entry##*:}"
    docker compose exec -T postgres psql -U datavow -d datavow_demo \
        -c "\\COPY $schema_table TO STDOUT WITH CSV HEADER" > "$DEMO_DIR/data/${filename}.csv" 2>/dev/null
    rows=$(tail -n +2 "$DEMO_DIR/data/${filename}.csv" | wc -l | tr -d ' ')
    printf "  %-35s → data/%s.csv (%s rows)\n" "$schema_table" "$filename" "$rows"
done

# ── Step 4: DataVow Validate (file-based) ────────────────────────────────────
header "Step 4: DataVow Validate (CSV files)"
info "Validating 10 contracts against exported data..."

VALIDATIONS=(
    "contracts/salesforce/account.yaml:data/salesforce_account.csv"
    "contracts/salesforce/contact.yaml:data/salesforce_contact.csv"
    "contracts/salesforce/opportunity.yaml:data/salesforce_opportunity.csv"
    "contracts/salesforce/lead.yaml:data/salesforce_lead.csv"
    "contracts/sap-erp/kna1-customers.yaml:data/sap_kna1.csv"
    "contracts/sap-erp/vbak-sales-orders.yaml:data/sap_vbak.csv"
    "contracts/sap-erp/mara-materials.yaml:data/sap_mara.csv"
    "contracts/odoo/res-partner.yaml:data/odoo_res_partner.csv"
    "contracts/odoo/sale-order.yaml:data/odoo_sale_order.csv"
    "contracts/odoo/product.yaml:data/odoo_product_product.csv"
)

for entry in "${VALIDATIONS[@]}"; do
    contract="${entry%%:*}"
    data="${entry##*:}"
    echo ""
    echo -e "${CYAN}──── $(basename $contract .yaml) ────${NC}"
    $DATAVOW validate "$contract" "$data" 2>&1 || true
done

# ── Step 5-7: dbt cycle ──────────────────────────────────────────────────────
if [ "$HAS_DBT" = true ]; then

    # ── Step 5: dbt sync ─────────────────────────────────────────────────────
    header "Step 5: datavow dbt sync"
    info "Generating dbt tests from contracts..."

    $DATAVOW dbt sync -c "$DEMO_DIR/contracts/" -p "$DBT_DIR" --clean 2>&1 || true

    SINGULAR=$(find "$DBT_DIR/tests" -name "*.sql" 2>/dev/null | wc -l | tr -d ' ')
    info "Generated $SINGULAR singular test files"

    # ── Step 6: dbt run + test ───────────────────────────────────────────────
    header "Step 6: dbt run + dbt test"

    cd "$DBT_DIR"
    export DBT_PROFILES_DIR="$DBT_DIR"

    step "dbt run (materialize staging models)..."
    dbt run 2>&1 || true

    step "dbt test --select tag:datavow"
    dbt test --select "tag:datavow" 2>&1 || true

    cd "$DEMO_DIR"

    # ── Step 7: datavow dbt validate ─────────────────────────────────────────
    header "Step 7: datavow dbt validate (warehouse connection)"
    info "Validating contracts directly against PostgreSQL..."

    cd "$DBT_DIR"
    $DATAVOW dbt validate \
        -c "$DEMO_DIR/contracts/" \
        --profiles "$DBT_DIR/profiles.yml" \
        --project-dir "$DBT_DIR" \
        --fail-on critical 2>&1 || true

    cd "$DEMO_DIR"

else
    header "Steps 5-7: Skipped (dbt not installed)"
    warn "Install dbt-postgres to see the full dbt cycle:"
    warn "  pip install dbt-postgres"
fi

# ── Summary ──────────────────────────────────────────────────────────────────
header "Demo Complete"
echo ""
info "What happened:"
info "  1. PostgreSQL started — 10 tables, 3 schemas, ~80 rows"
info "  2. Tables exported to CSV"
info "  3. datavow validate — 10 contracts checked against CSV files"
if [ "$HAS_DBT" = true ]; then
    info "  4. datavow dbt sync — generated dbt-native tests from contracts"
    info "  5. dbt run + dbt test — tests executed against PostgreSQL"
    info "  6. datavow dbt validate — direct warehouse validation"
fi
echo ""
info "Every contract has intentional violations — that's the point."
info "DataVow catches the issues before they reach production."
echo ""
info "Explore:"
info "  • CSV data:    ls data/"
info "  • Contracts:   ls contracts/*/"
if [ "$HAS_DBT" = true ]; then
    info "  • dbt tests:   ls dbt/tests/"
fi
echo ""
info "Cleanup: docker compose down"
echo ""
