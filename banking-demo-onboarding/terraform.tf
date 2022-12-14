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

resource "harness_platform_service" "new_service" {
  identifier  = "payments_validation_${replace(var.gitUser,"-","_")}"
  name        = "payments-validation-${var.gitUser}"
  description = "Banking Demo"
  org_id      = "default"
  tags       = ["team:latam", "banking-demo"]
  project_id  = "Demo_Sandbox"
  yaml        = <<-EOT
                service:
                  name: payments-validation-${var.gitUser}
                  description: description
                  identifier: payments_validation_${replace(var.gitUser,"-","_")}
                  serviceDefinition:
                    type: Kubernetes
                    spec:
                      manifests:
                        - manifest:
                            identifier: Template
                            type: K8sManifest
                            spec:
                              store:
                                type: Harness
                                spec:
                                  files:
                                    - account:/Diego/BankingApp/template/ingress/deployment-ingress.yaml
                                    - account:/Diego/BankingApp/template/ingress/ingress-service.yaml
                                    - account:/Diego/BankingApp/template/ingress/autostopping.yaml
                              valuesPaths:
                                - account:/Diego/BankingApp/environments/prod/banking-payments-validation/banking_payments_validation_prod_values.yaml
                              skipResourceVersioning: false
                      artifacts:
                        primary:
                          primaryArtifactRef: <+input>
                          sources:
                            - spec:
                                connectorRef: account.DockerHubDiego
                                imagePath: diegokoala/payments-validation
                                tag: <+pipeline.variables.tag>
                              identifier: ScanPay
                              type: DockerRegistry
                  gitOpsEnabled: false
              EOT
}

resource "harness_platform_environment" "se-env" {
  identifier  = lower(var.gitUser)
  name        = lower(var.gitUser)
  org_id     =  var.orgId
  project_id =  var.projectId
  tags       = ["team:latam", "banking-demo"]
  type       = "Production"
  yaml       = <<-EOT
               environment:
                name: ${lower(var.gitUser)}
                identifier: ${lower(var.gitUser)}
                orgIdentifier: ${var.orgId}
                projectIdentifier: ${var.projectId}
                type: Production
                variables:
                  - name: SEDEMO
                    type: String
                    value: v1
                    description: "Banking Demo"

      EOT
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
            payloadConditions: []
            headerConditions: []
            repoName: test
            actions:
              - Reopen
              - Open
    inputYaml: |
      pipeline: {}
    EOT
}