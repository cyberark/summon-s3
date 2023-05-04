#!/usr/bin/env groovy

pipeline {
  agent { label 'executor-v2' }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '30'))
  }

  triggers {
    cron(getDailyCronString())
  }

  stages {
    stage('Validate') {
      parallel {
        stage('Changelog') {
          steps { parseChangelog() }
        }
      }
    }

    stage('Build') {
      steps {
        sh './build.sh'
        sh 'sudo chown -R jenkins:jenkins .'  // temporary hack for docker root-owned files
      }
    }

    stage('Test') {
      steps { sh 'summon ./e2e_test.sh' }
    }

    stage('Package') {
      steps {
        sh './package.sh'
        archiveArtifacts artifacts: 'pkg/dist/*', fingerprint: true
      }
    }
  }

  post {
    always {
      cleanupAndNotify(currentBuild.currentResult)
    }
  }
}
