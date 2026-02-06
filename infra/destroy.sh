#!/bin/bash

# Destroy script for Rooms POC
# This script removes all infrastructure

set -e  # Exit on error

echo "╔════════════════════════════════════════╗"
echo "║   Rooms POC - Destroy Script         ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${RED}⚠️  WARNING: This will destroy all Rooms POC infrastructure!${NC}"
echo ""
echo "Resources that will be deleted:"
echo "  - SQS Queue (gini-dev-rooms-queue)"
echo "  - SQS DLQ (gini-dev-rooms-dlq)"
echo "  - EventBridge Event Bus"
echo "  - EventBridge Pipe"
echo "  - Lambda Function"
echo "  - IAM Roles and Policies"
echo "  - CloudWatch Log Groups"
echo ""

read -p "Are you sure you want to continue? (type 'destroy' to confirm): " confirm

if [ "$confirm" != "destroy" ]; then
    echo -e "${YELLOW}⚠️  Destruction cancelled${NC}"
    exit 0
fi

echo ""
echo "🗑️  Destroying infrastructure..."
terraform destroy -auto-approve

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Terraform destroy failed${NC}"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ All resources have been destroyed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

