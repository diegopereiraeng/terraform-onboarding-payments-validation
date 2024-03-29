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
  target_id  = "Banking_Validation_Pipeline"
  yaml       = <<-EOT
trigger:
  name: pr-${lower(var.gitUser)}
  identifier: pr_${lower(var.gitUser)}
  enabled: true
  orgIdentifier: ${var.orgId}
  projectIdentifier: ${var.projectId}
  pipelineIdentifier: Banking_Validation_Pipeline
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
              operator: Regex
              value: (master|authorization-ff|stable-version)
            - key: <+trigger.payload.pull_request.user.login>
              operator: Equals
              value: ${var.gitUser}
          repoName: payments-validation
          actions:
            - Open
            - Reopen
  inputYaml: |
    pipeline:
      identifier: Banking_Validation_Pipeline
      properties:
        ci:
          codebase:
            build:
              type: PR
              spec:
                number: <+trigger.prNumber>
      stages:
        - parallel:
            - stage:
                identifier: Deploy_Prod
                type: Deployment
                spec:
                  service:
                    serviceRef: payments_validation_${replace(lower(var.gitUser),"-","_")}
                    serviceInputs:
                      serviceDefinition:
                        type: Kubernetes
                        spec:
                          artifacts:
                            primary:
                              primaryArtifactRef: ScanPay
                              sources: ""
      variables:
        - name: virtualPath
          type: String
          value: <+<+trigger.gitUser>.toLowerCase()>
        - name: FF_Key
          type: String
          value: ${var.ffKey}
        - name: firstDeploy
          type: String
          value: "false"
    EOT
}

resource "harness_platform_triggers" "trigger-banking-front" {
  identifier  = "pr_${lower(var.gitUser)}_front"
  name        = "pr-${lower(var.gitUser)}_front"
  org_id     =  var.orgId
  project_id =  var.projectId
  target_id  = "Production_Git_Flow"
  yaml       = <<-EOT
trigger:
  name: pr-${lower(var.gitUser)}
  identifier: pr_${lower(var.gitUser)}
  enabled: true
  orgIdentifier: ${var.orgId}
  projectIdentifier: ${var.projectId}
  pipelineIdentifier: Production_Git_Flow
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
              value: dev
            - key: <+trigger.payload.pull_request.user.login>
              operator: Equals
              value: ${var.gitUser}
          repoName: gitflow-ff-demo
          actions:
            - Open
            - Reopen
  inputYaml: |
    pipeline:
      identifier: Production_Git_Flow
      properties:
        ci:
          codebase:
            build:
              type: PR
              spec:
                number: <+trigger.prNumber>
      variables:
        - name: tag
          type: String
          value: ${replace(lower(var.gitUser),"-","_")}
        - name: ffkey
          type: String
          value: ${var.ffKeyFront}
        - name: virtualPath
          type: String
          value: ${replace(lower(var.gitUser),"-","_")}
        - name: gitEvent
          type: String
          value: PR
        - name: target
          type: String
          value: dev
        - name: branch
          type: String
          value: <+trigger.sourceBranch>
    EOT
}
