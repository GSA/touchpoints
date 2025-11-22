#!/bin/bash

# Script to extract Zscaler certificate from various system locations
# This helps identify and copy the Zscaler certificate for Docker builds

set -e

echo "Zscaler Certificate Extraction Tool"
echo "=================================="

# Common Zscaler certificate names and locations
CERT_NAMES=(
    "Zscaler Root CA"
    "ZscalerRootCertificate-2048-SHA256"
    "Zscaler Intermediate Root CA"
    "zscaler"
)

# macOS Keychain locations
if command -v security >/dev/null 2>&1; then
    echo "Searching macOS Keychain for Zscaler certificates..."
    
    for cert_name in "${CERT_NAMES[@]}"; do
        echo "  Checking for: $cert_name"
        
        # Try to find and export the certificate
        if security find-certificate -c "$cert_name" -p /System/Library/Keychains/SystemRootCertificates.keychain >/dev/null 2>&1; then
            echo "    Found in SystemRootCertificates keychain"
            security find-certificate -c "$cert_name" -p /System/Library/Keychains/SystemRootCertificates.keychain > "zscaler-${cert_name// /-}.crt" 2>/dev/null
            echo "    Exported to: zscaler-${cert_name// /-}.crt"
        elif security find-certificate -c "$cert_name" -p /Library/Keychains/System.keychain >/dev/null 2>&1; then
            echo "    Found in System keychain"
            security find-certificate -c "$cert_name" -p /Library/Keychains/System.keychain > "zscaler-${cert_name// /-}.crt" 2>/dev/null
            echo "    Exported to: zscaler-${cert_name// /-}.crt"
        elif security find-certificate -c "$cert_name" -p ~/Library/Keychains/login.keychain-db >/dev/null 2>&1; then
            echo "    Found in login keychain"
            security find-certificate -c "$cert_name" -p ~/Library/Keychains/login.keychain-db > "zscaler-${cert_name// /-}.crt" 2>/dev/null
            echo "    Exported to: zscaler-${cert_name// /-}.crt"
        fi
    done
fi

# Check common certificate directories
CERT_DIRS=(
    "/usr/local/share/ca-certificates"
    "/etc/ssl/certs"
    "/etc/pki/ca-trust/source/anchors"
    "/usr/share/ca-certificates"
)

echo ""
echo "Searching common certificate directories..."
for dir in "${CERT_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "  Checking: $dir"
        find "$dir" -name "*zscaler*" -o -name "*Zscaler*" 2>/dev/null | while read -r cert_file; do
            echo "    Found: $cert_file"
            cp "$cert_file" "./$(basename "$cert_file")" 2>/dev/null || true
        done
    fi
done

# Check if we can download from a Zscaler-intercepted connection
echo ""
echo "Attempting to extract certificate from HTTPS connection..."
if command -v openssl >/dev/null 2>&1; then
    # Try to get the certificate from a known HTTPS site
    echo "  Testing connection to github.com..."
    echo | openssl s_client -showcerts -connect github.com:443 2>/dev/null | \
    awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/{print}' | \
    csplit -s -f cert- - '/-----END CERTIFICATE-----/+1' {*} 2>/dev/null || true
    
    # Check if any of the certificates are from Zscaler
    for cert_file in cert-*; do
        if [ -f "$cert_file" ]; then
            cert_info=$(openssl x509 -in "$cert_file" -text -noout 2>/dev/null | grep -i zscaler || true)
            if [ -n "$cert_info" ]; then
                echo "    Found Zscaler certificate in connection chain"
                cp "$cert_file" "zscaler-intercepted.crt"
                echo "    Saved as: zscaler-intercepted.crt"
            fi
            rm "$cert_file" 2>/dev/null || true
        fi
    done
fi

# Summary of found certificates
echo ""
echo "Found Zscaler Certificates:"
echo "=========================="
found_any=false

for cert_file in zscaler*.crt Zscaler*.crt; do
    if [ -f "$cert_file" ] && openssl x509 -in "$cert_file" -text -noout >/dev/null 2>&1; then
        echo "✓ $cert_file"
        echo "  Subject: $(openssl x509 -in "$cert_file" -subject -noout 2>/dev/null | sed 's/subject=//')"
        echo "  Issuer:  $(openssl x509 -in "$cert_file" -issuer -noout 2>/dev/null | sed 's/issuer=//')"
        echo ""
        found_any=true
        
        # Create a standardized name for the Docker build
        cp "$cert_file" "zscaler-cert.crt"
        echo "  → Copied to zscaler-cert.crt for Docker build"
        echo ""
    fi
done

if [ "$found_any" = false ]; then
    echo "❌ No valid Zscaler certificates found"
    echo ""
    echo "Manual extraction options:"
    echo "1. Export from browser certificate store"
    echo "2. Contact your IT department for the certificate file"
    echo "3. Use browser to visit https://github.com and export the root certificate"
    echo ""
    echo "Once you have the certificate file:"
    echo "  cp /path/to/your/zscaler-cert.pem ./zscaler-cert.crt"
else
    echo "✅ Ready to build Docker image with Zscaler certificate support"
    echo "   Run: ./build-docker-with-cert.sh"
fi