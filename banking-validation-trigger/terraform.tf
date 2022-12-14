terraform {
  required_providers {
    harness = {
      source = "harness/harness"
      version = "0.11.4"
    }
  }
}

provider "harness" {
    endpoint   = "https://app.harness.io/gateway"
    account_id = var.accId
    platform_api_key  = var.apiKey
}



resource "harness_platform_triggers" "trigger-banking" {
  identifier  = "pr_${lower(var.gitUser)}"
  name        = "pr-${lower(var.gitUser)}"
  org_id     =  var.orgId
  project_id =  var.projectId
  target_id  = "DiegoautomationTest"
  yaml       = <<-EOT
trigger:
  name: pr-${lower(var.gitUser)}
  identifier: pr_${lower(var.gitUser)}
  enabled: true
  description: ""
  tags: {}
  orgIdentifier: ${var.orgId}
  projectIdentifier: ${var.projectId}
  pipelineIdentifier: DiegoautomationTest
  source:
    type: Webhook
    spec:
      type: Github
      spec:
        type: PullRequest
        spec:
          connectorRef: account.diegogithubapp
          autoAbortPreviousExecutions: false
          payloadConditions:
            - key: targetBranch
              operator: Equals
              value: master
          headerConditions: []
          repoName: test
          actions:
            - Reopen
            - Open
  inputYaml: |
    pipeline:
      identifier: DiegoautomationTest
      variables:
        - name: gitUser
          type: String
          value: ${var.gitUser}
        - name: FF_Key
          type: String
          value: ${var.ffKey}
    EOT
}