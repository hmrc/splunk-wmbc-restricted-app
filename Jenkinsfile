#!/usr/bin/env groovy

pipeline {
  agent {
    label 'commonagent'
  }

  environment {
    IS_RELEASE = 'true'
  }
  
  stages {
    stage('Build app') {
      steps {
        sh('make ci/build')
      }
    }
    stage('Publish app') {
      steps {
        ansiColor('xterm') {
          withCredentials([usernamePassword(credentialsId: 'artifactory_api_access', passwordVariable: 'ARTIFACTORY_PASSWORD', usernameVariable: 'ARTIFACTORY_USERNAME')]) {
            sh('make ci/publish')
          }
        }
      }
    }
    stage('Tag app Release') {
      steps {
        sh('make ci/tag')
      }
    }
  }

  post {
    always {
      sh('make clean')
    }
  }
}
