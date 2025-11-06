#!/usr/bin/env groovy
@Library("product-pipelines-shared-library") _

// Automated release, promotion and dependencies
properties([
  // Include the automated release parameters for the build
  release.addParams(),
  // Dependencies of the project that should trigger builds
  dependencies([])
])

// Performs release promotion.  No other stages will be run
if (params.MODE == "PROMOTE") {
  release.promote(params.VERSION_TO_PROMOTE) { infrapool, sourceVersion, targetVersion, assetDirectory ->
  }
  release.copyEnterpriseRelease(params.VERSION_TO_PROMOTE)
  return
}

pipeline {
  agent { label 'conjur-enterprise-common-agent' }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '30'))
  }

  triggers {
    cron(getDailyCronString())
    parameterizedCron(getWeeklyCronString("H(1-5)","%MODE=RELEASE"))
  }

  environment {
    // Sets the MODE to the specified or autocalculated value as appropriate
    MODE = release.canonicalizeMode()
  }

  stages {
    // Aborts any builds triggered by another project that wouldn't include any changes
    stage ("Skip build if triggering job didn't create a release") {
      when {
        expression {
          MODE == "SKIP"
        }
      }
      steps {
        script {
          currentBuild.result = 'ABORTED'
          error("Aborting build because this build was triggered from upstream, but no release was built")
        }
      }
    }

    stage('Scan for internal URLs') {
      steps {
        script {
          detectInternalUrls()
        }
      }
    }

    stage('Get InfraPool Agent') {
      steps {
        script {
          INFRAPOOL_EXECUTORV2_AGENT_0 = getInfraPoolAgent.connected(type: "ExecutorV2", quantity: 1, duration: 1)[0]
        }
      }
    }

    stage('Validate') {
      parallel {
        stage('Changelog') {
          steps { parseChangelog(INFRAPOOL_EXECUTORV2_AGENT_0) }
        }
      }
    }

    // Generates a VERSION file based on the current build number and latest version in CHANGELOG.md
    stage('Validate changelog and set version') {
      steps {
        updateVersion(INFRAPOOL_EXECUTORV2_AGENT_0, "CHANGELOG.md", "${BUILD_NUMBER}")
      }
    }

    stage('Build') {
      steps {
        script {
          INFRAPOOL_EXECUTORV2_AGENT_0.agentDir('./pristine-checkout') {
            // Go releaser requires a pristine checkout
            checkout scm

            // Copy the checkout content onto infrapool
            INFRAPOOL_EXECUTORV2_AGENT_0.agentPut from: "./", to: "."

            // Copy VERSION info into prisitine folder
            INFRAPOOL_EXECUTORV2_AGENT_0.agentSh "cp ../VERSION ./VERSION"

            INFRAPOOL_EXECUTORV2_AGENT_0.agentSh './build.sh'
            INFRAPOOL_EXECUTORV2_AGENT_0.agentArchiveArtifacts artifacts: 'dist/goreleaser/'
          }
        }
      }
    }

    stage('Test') {
      steps {
        script {
          // Use the artifacts from the previous stage
          INFRAPOOL_EXECUTORV2_AGENT_0.agentDir('./pristine-checkout') {
            INFRAPOOL_EXECUTORV2_AGENT_0.agentSh 'summon ./e2e_test.sh' 
          }
        }
      }
    }

    stage('Release') {
      when {
        expression {
          MODE == "RELEASE"
        }
      }
      steps {
        script {
          release(INFRAPOOL_EXECUTORV2_AGENT_0) { billOfMaterialsDirectory, assetDirectory, toolsDirectory ->
            // Publish release artifacts to all the appropriate locations
            // Copy any artifacts to assetDirectory to attach them to the Github release

            // Copy assets to be published in Github release.
            INFRAPOOL_EXECUTORV2_AGENT_0.agentSh "${toolsDirectory}/bin/copy_goreleaser_artifacts ${assetDirectory}"

            // Create Go application SBOM using the go.mod version for the golang container image
            INFRAPOOL_EXECUTORV2_AGENT_0.agentSh """
              export PATH="${toolsDirectory}/bin:\${PATH}"
              go-bom --tools "${toolsDirectory}" --go-mod ./go.mod --image "golang" --main "./" --output "${billOfMaterialsDirectory}/go-app-bom.json"
            """

            // Create Go module SBOM
            INFRAPOOL_EXECUTORV2_AGENT_0.agentSh """
              export PATH="${toolsDirectory}/bin:\${PATH}"
              go-bom --tools "${toolsDirectory}" --go-mod ./go.mod --image "golang" --output "${billOfMaterialsDirectory}/go-mod-bom.json"
            """
          }
        }
      }
    }
  }

  post {
    always {
      releaseInfraPoolAgent(".infrapool/release_agents")
    }
  }
}
