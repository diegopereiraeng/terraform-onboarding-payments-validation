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
  identifier  = "payments_validation_${lower(replace(var.gitUser,"-","_"))}"
  name        = "payments-validation-${lower(var.gitUser)}"
  description = "Banking Demo"
  org_id      = "default"
  tags       = ["team:latam", "banking-demo"]
  project_id  = "GIT_FLOW_DEMO"
  yaml        = <<-EOT
                service:
                  name: payments-validation-${lower(var.gitUser)}
                  description: description
                  identifier: payments_validation_${lower(replace(var.gitUser,"-","_"))}
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
                                tag: <+pipeline.stages.Build.spec.execution.steps.Export_Tag_Version.output.outputVariables.release>
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
                identifier: ${replace(lower(var.gitUser),"-","_")}
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

