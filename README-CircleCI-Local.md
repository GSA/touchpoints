# Running CircleCI Jobs Locally

This document explains how to run CircleCI jobs locally using the CircleCI CLI, including solutions for ARM64 compatibility issues.

## Overview

We successfully demonstrated running a CircleCI job locally using the CircleCI CLI tool. The approach works for environment setup and dependency installation, though SSL certificate issues in container environments remain a limitation.

## Prerequisites

1. **CircleCI CLI**: Install the CircleCI CLI tool
   ```bash
   # macOS with Homebrew
   brew install circleci
   
   # Or download from: https://github.com/CircleCI-Public/circleci-cli/releases
   ```

2. **Docker**: Required for local execution
   ```bash
   # Verify Docker is running
   docker --version
   ```

## Available Configurations

We created several configuration files to handle different scenarios:

### 1. `working-local-config.yml` - Most Compatible
- Uses `ruby:3.2.8-slim` (ARM64 compatible)
- Installs Node.js via Debian packages
- Handles basic SSL certificate issues
- Demonstrates full job execution flow

### 2. `final-local-config.yml` - SSL Workaround Attempt  
- Comprehensive SSL certificate handling
- Disables SSL verification for local testing
- Most complete environment setup

### 3. `simple-local-config.yml` - Minimal Setup
- Basic single-container setup
- Good for understanding CircleCI CLI basics

## Usage

### Basic Execution
```bash
# Run with the most compatible configuration
circleci local execute -c working-local-config.yml build

# Or with comprehensive SSL handling
circleci local execute -c final-local-config.yml build
```

### Validate Configuration First
```bash
# Check if your config is valid
circleci config validate .circleci/config.yml
```

## What Works Successfully

✅ **Environment Setup**
- Docker container creation and management
- System package installation (PostgreSQL client, build tools, etc.)
- Ruby environment configuration
- Node.js and npm installation via system packages

✅ **Code Management** 
- Repository checkout
- File copying and workspace setup

✅ **Dependency Management (Partial)**
- Bundle configuration
- Package manager setup
- Basic gem installation (when SSL allows)

## Current Limitations

❌ **SSL Certificate Issues**
- Container environments have SSL certificate verification problems
- Affects both RubyGems and GitHub access
- Workarounds help but don't completely solve the issue

❌ **Service Dependencies**
- No PostgreSQL or Redis services in local execution
- Database tests require external service setup

❌ **Platform Compatibility Warnings**
- ARM64 vs AMD64 architecture mismatches
- Works but generates warnings

## Platform Compatibility Solutions

### Original Issue
The CircleCI config uses `cimg/ruby:3.2.8-browsers` which isn't available for ARM64.

### Solution
Switch to `ruby:3.2.8-slim` which supports ARM64:
```yaml
docker:
  - image: ruby:3.2.8-slim  # ARM64 compatible
```

### Node.js Installation Fix
Use Debian packages instead of NodeSource repository to avoid SSL issues:
```yaml
- run:
    name: Install Node.js
    command: |
      apt-get update
      apt-get install -y nodejs npm
```

## Recommended Workflow

1. **Start with validation**:
   ```bash
   circleci config validate .circleci/config.yml
   ```

2. **Test basic setup**:
   ```bash
   circleci local execute -c simple-local-config.yml build
   ```

3. **Run comprehensive test**:
   ```bash
   circleci local execute -c working-local-config.yml build
   ```

4. **Debug issues**:
   - Check Docker logs
   - Verify image availability
   - Test individual commands in containers

## Alternative Approaches

If SSL issues persist, consider:

1. **Direct Docker execution**:
   ```bash
   docker run -it ruby:3.2.8-slim bash
   # Run commands manually
   ```

2. **Custom Dockerfile**:
   Create a Dockerfile that replicates the CI environment without SSL issues.

3. **GitHub Actions Alternative**:
   Use Act (https://github.com/nektos/act) to run GitHub Actions locally.

## Files Created

- `working-local-config.yml` - Primary working configuration
- `final-local-config.yml` - Complete SSL workaround attempt  
- `simple-local-config.yml` - Minimal setup for testing
- `local-config.yml` - Initial ARM64 compatibility fix
- `process.yml` - Processed version from original config

## Key Learnings

1. **CircleCI CLI works well** for local job execution
2. **Platform compatibility** is solvable with appropriate base images
3. **SSL certificate issues** in containers require network-level solutions
4. **Local execution is valuable** for debugging CI setup even with limitations
5. **ARM64 support** requires careful image selection

## Conclusion

The CircleCI CLI successfully demonstrates local job execution and is valuable for:
- Testing CI configuration changes
- Debugging environment setup issues  
- Understanding job execution flow
- Validating dependency installation

While SSL certificate issues remain a challenge, the approach provides significant value for CI/CD development and debugging workflows.