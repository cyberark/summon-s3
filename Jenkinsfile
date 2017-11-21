#!/usr/bin/env groovy

pipeline {
  agent { label 'executor-v2' }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '30'))
  }

  stages {
    stage('Build') {
      steps {
        sh './build.sh'
      }
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
