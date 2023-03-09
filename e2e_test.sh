#!/bin/bash -e

# Run this script using summon
# summon --provider summon-conjur ./e2e_test.sh

REQUIRED_VARS=(AWS_REGION AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY)
SUMMON_DIR=summon-"$(uuidgen | tr "[:upper:]" "[:lower:]" | head -c 12 | tr -d -)"
export AWS_BUCKET="summon-s3-ci"
export AWS_ARTIFACT="ci-secret.txt"

function finish {
  rm -rf $SUMMON_DIR
}

trap finish EXIT

function main {
    check_required_vars
    build_summon_image
    test_output "test secret"
}

function check_required_vars {
    for var in "${REQUIRED_VARS[@]}"; do
        if [[ -z "${!var}" ]]; then
            echo "$var is not set"
            exit 1
        fi
    done
}

function build_summon_image {
    git clone "https://github.com/cyberark/summon.git" $SUMMON_DIR
    pushd $SUMMON_DIR > /dev/null
    docker build . -t test-summon
    popd > /dev/null
}

# Helper function to build and run the Docker container
function test_output {
    local expected_output="$1"
    local output=$(docker run --rm \
        --entrypoint=/bin/sh \
        -v "$PWD":/summon-s3-src -w /summon-s3-src \
        -e AWS_REGION -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_BUCKET -e AWS_ARTIFACT \
        test-summon -c "
          ./$SUMMON_DIR/install.sh > /dev/null && \
          summon --provider ./pkg/linux/summon-s3 \
          --yaml \"TEST_CRED: !var $AWS_BUCKET/$AWS_ARTIFACT\" \
          printenv TEST_CRED") || true

    if [ "$output" == "$expected_output" ] && [ $? -eq 0 ]; then
        echo "Test passed"
        exit 0
    else
        echo "Test failed"
        echo "Expected output to equal: '$expected_output'. Actual output: $output"
        exit 1
    fi
}

main
