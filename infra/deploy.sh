#!/bin/bash

# Deploy script for Rooms POC
# This script automates the deployment of the infrastructure

set -e  # Exit on error

echo "╔════════════════════════════════════════╗"
echo "║   Rooms POC - Deployment Script      ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform is not installed. Please install it first.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Terraform found${NC}"

# Check if AWS credentials are set
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo -e "${YELLOW}⚠️  AWS credentials not found in environment${NC}"
    echo "Please set the following environment variables:"
    echo "  - AWS_ACCESS_KEY_ID"
    echo "  - AWS_SECRET_ACCESS_KEY"
    echo "  - AWS_SESSION_TOKEN (optional)"
    echo ""
    echo "Or run: export AWS_ACCESS_KEY_ID=your_key"
    exit 1
fi

echo -e "${GREEN}✓ AWS credentials configured${NC}"
echo ""

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init -backend-config=backend.tfbackend

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Terraform init failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Terraform initialized${NC}"
echo ""

# Show plan
echo "📋 Creating execution plan..."
terraform plan -out=tfplan

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Terraform plan failed${NC}"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Ask for confirmation
read -p "Do you want to apply these changes? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo -e "${YELLOW}⚠️  Deployment cancelled${NC}"
    rm -f tfplan
    exit 0
fi

# Apply changes
echo ""
echo "🚀 Deploying infrastructure..."
terraform apply tfplan

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Terraform apply failed${NC}"
    rm -f tfplan
    exit 1
fi

# Clean up plan file
rm -f tfplan

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Show important outputs
echo "📊 Important Outputs:"
echo ""
echo "SQS Queue URL:"
terraform output sqs_queue_url
echo ""
echo "Lambda Function:"
terraform output lambda_function_name
echo ""
echo "Event Bus:"
terraform output event_bus_name
echo ""

# Show next steps
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Next Steps:"
echo ""
echo "1. Copy the SQS Queue URL above"
echo "2. Add it to your backend .env file (../backend/.env):"
echo "   ROOMS_QUEUE_URL=<queue_url>"
echo ""
echo "3. Start your backend:"
echo "   cd ../backend"
echo "   npm run start:dev"
echo ""
echo "4. Test the endpoint:"
echo "   curl -X POST http://localhost:3001/rooms/message \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -d '{\"email1\":\"test@test.com\",\"email2\":\"test2@test.com\",\"roomId\":\"test-123\"}'"
echo ""
echo "5. Check Lambda logs:"
echo "   aws logs tail /aws/lambda/gini-dev-rooms-processor --follow"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

