#!/bin/bash
set -euo pipefail

# DevSecOps Platform - Complete Teardown
# Usage: ./scripts/destroy.sh

echo "🗑️  DevSecOps Platform Teardown"
echo "==============================="

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

cd terraform/environments/dev

echo -e "${YELLOW}⚠️  This will DESTROY all resources!${NC}"
read -p "Are you sure? Type 'destroy' to confirm: " confirm

if [ "$confirm" != "destroy" ]; then
    echo "Aborted."
    exit 1
fi

echo "Destroying infrastructure..."
terraform destroy -auto-approve

echo ""
echo -e "${GREEN}✅ Infrastructure destroyed${NC}"

echo ""
echo -e "${YELLOW}Manual cleanup checklist:${NC}"
echo "  [ ] ECR repositories (images may persist)"
echo "  [ ] CloudWatch log groups"
echo "  [ ] S3 buckets (check for leftover logs)"
echo "  [ ] GuardDuty findings (auto-deleted with detector)"
echo "  [ ] Security Hub (disable if no longer needed)"

echo ""
echo -e "${GREEN}💰 Credits preserved!${NC}"
