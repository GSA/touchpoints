#!/usr/bin/env bash
set -e

echo "======================================"
echo "AWS Bedrock Credentials Fix"
echo "======================================"
echo ""

# Set the AWS config file path from your SSO login script
export AWS_CONFIG_FILE="/Users/rileydseaburg/Documents/programming/aigov-core-keycloak-terraform/.aws/config"

echo "Setting AWS configuration..."
echo "AWS_CONFIG_FILE: $AWS_CONFIG_FILE"

# Test if the config file exists
if [[ ! -f "$AWS_CONFIG_FILE" ]]; then
    echo "❌ AWS config file not found at: $AWS_CONFIG_FILE"
    echo "Please run your SSO login script first:"
    echo "cd /Users/rileydseaburg/Documents/programming/aigov-core-keycloak-terraform/scripts"
    echo "./aws-sso-login.sh"
    exit 1
fi

echo "✓ AWS config file found"
echo ""

# Check if SSO session is still valid
echo "Testing AWS SSO authentication..."
if aws sts get-caller-identity --profile gsai &>/dev/null; then
    echo "✓ AWS SSO session is active"
    echo ""
    echo "Current identity:"
    aws sts get-caller-identity --profile gsai --output table
    echo ""
else
    echo "❌ AWS SSO session expired or invalid"
    echo "Please re-run the SSO login:"
    echo "cd /Users/rileydseaburg/Documents/programming/aigov-core-keycloak-terraform/scripts"
    echo "./aws-sso-login.sh"
    exit 1
fi

# Set environment variables for Bedrock
export AWS_PROFILE=gsai
export AWS_DEFAULT_REGION=us-east-1

echo "Setting environment variables for Bedrock:"
echo "AWS_PROFILE: $AWS_PROFILE"
echo "AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION"
echo ""

# Test Bedrock access
echo "Testing Bedrock access..."
if aws bedrock list-foundation-models --region us-east-1 --query 'modelSummaries[?contains(modelId, `claude`)].{ModelId:modelId,Status:modelStatus}' --output table 2>/dev/null; then
    echo ""
    echo "✓ Bedrock access successful!"
else
    echo "❌ Bedrock access failed. Trying us-west-2..."
    export AWS_DEFAULT_REGION=us-west-2
    if aws bedrock list-foundation-models --region us-west-2 --query 'modelSummaries[?contains(modelId, `claude`)].{ModelId:modelId,Status:modelStatus}' --output table 2>/dev/null; then
        echo ""
        echo "✓ Bedrock access successful in us-west-2!"
        echo "Note: Set AWS_DEFAULT_REGION=us-west-2 for future use"
    else
        echo "❌ Bedrock access failed in both regions"
        echo ""
        echo "Possible issues:"
        echo "1. Claude models not enabled in your AWS account"
        echo "2. Insufficient IAM permissions for Bedrock"
        echo "3. Bedrock not available in your regions"
        echo ""
        echo "Next steps:"
        echo "1. Visit AWS Bedrock console: https://console.aws.amazon.com/bedrock/"
        echo "2. Go to Model access and request access to Claude models"
        echo "3. Ensure your IAM role has bedrock:* permissions"
        exit 1
    fi
fi

echo ""
echo "======================================"
echo "✓ Setup Complete!"
echo "======================================"
echo ""
echo "To use Bedrock in this terminal session, run:"
echo "export AWS_CONFIG_FILE=\"$AWS_CONFIG_FILE\""
echo "export AWS_PROFILE=gsai"
echo "export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION"
echo ""
echo "Or add these to your ~/.zshrc for permanent setup:"
echo "echo 'export AWS_CONFIG_FILE=\"$AWS_CONFIG_FILE\"' >> ~/.zshrc"
echo "echo 'export AWS_PROFILE=gsai' >> ~/.zshrc"
echo "echo 'export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION' >> ~/.zshrc"
echo ""
