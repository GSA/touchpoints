#!/usr/bin/env bash
set -e

echo "======================================"
echo "AWS Bedrock Credentials Debug Script"
echo "======================================"
echo ""

# Check current AWS identity
echo "1. Checking current AWS identity..."
aws sts get-caller-identity --profile gsai 2>/dev/null || {
    echo "❌ Failed to get caller identity with gsai profile"
    echo "Trying without profile..."
    aws sts get-caller-identity 2>/dev/null || {
        echo "❌ No valid AWS credentials found"
        exit 1
    }
}

echo ""
echo "2. Listing available AWS profiles..."
aws configure list-profiles

echo ""
echo "3. Checking AWS credential configuration..."
aws configure list --profile gsai

echo ""
echo "4. Testing Bedrock access (us-east-1)..."
echo "Available foundation models:"
aws bedrock list-foundation-models --profile gsai --region us-east-1 --query 'modelSummaries[?contains(modelId, `claude`)].{ModelId:modelId,Status:modelStatus}' --output table 2>/dev/null || {
    echo "❌ Failed to access Bedrock in us-east-1"
    echo "This could be due to:"
    echo "  - Insufficient permissions"
    echo "  - Bedrock not available in this region"
    echo "  - Model access not granted"
}

echo ""
echo "5. Testing Bedrock access (us-west-2)..."
echo "Available foundation models in us-west-2:"
aws bedrock list-foundation-models --profile gsai --region us-west-2 --query 'modelSummaries[?contains(modelId, `claude`)].{ModelId:modelId,Status:modelStatus}' --output table 2>/dev/null || {
    echo "❌ Failed to access Bedrock in us-west-2"
}

echo ""
echo "6. Checking environment variables..."
echo "AWS_PROFILE: ${AWS_PROFILE:-'not set'}"
echo "AWS_DEFAULT_REGION: ${AWS_DEFAULT_REGION:-'not set'}"
echo "AWS_REGION: ${AWS_REGION:-'not set'}"
echo "AWS_CONFIG_FILE: ${AWS_CONFIG_FILE:-'not set'}"

echo ""
echo "======================================"
echo "Potential Solutions:"
echo "======================================"
echo ""
echo "If Bedrock access fails, try these solutions:"
echo ""
echo "1. Set the correct AWS profile:"
echo "   export AWS_PROFILE=gsai"
echo ""
echo "2. Set the region where Bedrock is available:"
echo "   export AWS_DEFAULT_REGION=us-east-1"
echo "   # or"
echo "   export AWS_DEFAULT_REGION=us-west-2"
echo ""
echo "3. Request access to Claude models in Bedrock console:"
echo "   https://console.aws.amazon.com/bedrock/home#/modelaccess"
echo ""
echo "4. Ensure your IAM role has Bedrock permissions:"
echo "   - bedrock:InvokeModel"
echo "   - bedrock:InvokeModelWithResponseStream"
echo "   - bedrock:ListFoundationModels"
echo ""
echo "5. If using SSO, ensure the config file is properly set:"
echo "   export AWS_CONFIG_FILE=/path/to/your/.aws/config"
echo ""
