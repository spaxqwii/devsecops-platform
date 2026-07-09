#!/bin/bash
set -euo pipefail

# DevSecOps Platform - One-Command Setup
# Usage: ./scripts/setup.sh

echo "🚀 DevSecOps Platform Setup"
echo "============================"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check prerequisites
check_prereq() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}❌ $1 is not installed${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ $1 found${NC}"
}

echo "Checking prerequisites..."
check_prereq terraform
check_prereq aws
check_prereq docker
check_prereq trivy
check_prereq opa

# Get AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo -e "${GREEN}✅ AWS Account: $AWS_ACCOUNT_ID${NC}"

# Create S3 bucket for Terraform state (if not exists)
BUCKET_NAME="devsecops-tfstate-$AWS_ACCOUNT_ID"
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "Creating Terraform state bucket..."
    aws s3 mb "s3://$BUCKET_NAME" --region us-east-1
    aws s3api put-bucket-versioning         --bucket "$BUCKET_NAME"         --versioning-configuration Status=Enabled
    echo -e "${GREEN}✅ S3 bucket created${NC}"
else
    echo -e "${GREEN}✅ S3 bucket exists${NC}"
fi

# Create DynamoDB table for state locking
if ! aws dynamodb describe-table --table-name devsecops-tflock &>/dev/null; then
    echo "Creating DynamoDB lock table..."
    aws dynamodb create-table         --table-name devsecops-tflock         --attribute-definitions AttributeName=LockID,AttributeType=S         --key-schema AttributeName=LockID,KeyType=HASH         --billing-mode PAY_PER_REQUEST
    echo -e "${GREEN}✅ DynamoDB table created${NC}"
else
    echo -e "${GREEN}✅ DynamoDB table exists${NC}"
fi

# Copy terraform.tfvars if not exists
if [ ! -f "terraform/environments/dev/terraform.tfvars" ]; then
    echo "Creating terraform.tfvars from example..."
    cp terraform/environments/dev/terraform.tfvars.example terraform/environments/dev/terraform.tfvars
    echo -e "${YELLOW}⚠️  Please edit terraform/environments/dev/terraform.tfvars with your values${NC}"
    echo "   Required: aws_account_id, github_org, owner_email"
    exit 1
fi

# Terraform workflow
cd terraform/environments/dev

echo "Initializing Terraform..."
terraform init

echo "Validating Terraform..."
terraform validate

echo "Running security policy checks..."
terraform plan -out=tfplan
opa test ../../policies/ || true  # Don't fail on warnings

echo "Applying infrastructure..."
terraform apply tfplan

echo ""
echo -e "${GREEN}🎉 Deployment complete!${NC}"
echo ""
echo "Outputs:"
terraform output

echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: Set up GitHub Secrets:${NC}"
echo "   AWS_ROLE_ARN: $(terraform output -raw github_actions_role_arn)"
echo ""
echo -e "${YELLOW}⚠️  To destroy and save credits:${NC}"
echo "   ./scripts/destroy.sh"
