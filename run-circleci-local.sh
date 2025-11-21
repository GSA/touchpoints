#!/bin/bash

echo "Running CircleCI job locally using Docker..."
echo "This will:"
echo "1. Build the CircleCI environment using the same Ruby image and dependencies"
echo "2. Start PostgreSQL and Redis services"
echo "3. Run the full test suite as defined in .circleci/config.yml"
echo ""

# Build and run the CircleCI environment
docker-compose -f docker-compose.circleci.yml up --build --abort-on-container-exit

echo ""
echo "CircleCI job completed. Check the output above for test results."
echo "Test results are also saved in the test_results volume."

# Optional: Show test results
echo ""
echo "To view detailed test results:"
echo "docker-compose -f docker-compose.circleci.yml run --rm circleci-test cat /tmp/test-results/rspec.xml"

# Cleanup
echo ""
echo "To cleanup (remove containers and volumes):"
echo "docker-compose -f docker-compose.circleci.yml down -v"