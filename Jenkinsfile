#!/usr/bin/env groovy

pipeline {
  agent { label 'conjur-enterprise-common-agent' }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '30'))
  }

  triggers {
    cron(getDailyCronString())
  }

  stages {
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

    stage('Build') {
      steps {
        script {
          INFRAPOOL_EXECUTORV2_AGENT_0.agentSh './build.sh'
          INFRAPOOL_EXECUTORV2_AGENT_0.agentSh 'sudo chown -R jenkins:jenkins .'  // temporary hack for docker root-owned files
        }
      }
    }

    stage('Test') {
      steps { script { INFRAPOOL_EXECUTORV2_AGENT_0.agentSh 'summon ./e2e_test.sh' } }
    }

    stage('Package') {
      steps {
        script {
          INFRAPOOL_EXECUTORV2_AGENT_0.agentSh './package.sh'
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
