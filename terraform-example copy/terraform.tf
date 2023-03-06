terraform {
  required_providers {
    harness = {
      source = "harness/harness"
      version = "0.14.3"
    }
  }
}

provider "harness" {
    endpoint   = "https://app.harness.io/gateway"
    account_id = "o5wblwnMQO-4TvX6-3MY2w"
}




resource "harness_platform_pipeline" "harnessdemoci" {
  name = "harnessdemoci"
  identifier = "harnessdemoci"
  org_id = "default"
  project_id = "default_project"
#   template_applied = true
#   git_details {
#     branch_name = "harness-integration"
#     commit_message = "ci: Created pipeline in harness"
#     file_path = ".harness/harness_demo_ci.yaml"
#     connector_ref = "account.ghdevopsocc"
#     store_type = "REMOTE"
#     repo_name = "harness-demo-ci"
#   }
  yaml = <<-EOT
      pipeline:
          name: harnessdemoci
          identifier: harnessdemoci
          projectIdentifier: default_project
          orgIdentifier: default
          tags: {}
          properties:
              ci:
                codebase:
                    connectorRef: account.ghdevopsocc
                    repoName: diego-repo
                    build: <+input>
          stages:
              - stage:
                  name: test
                  identifier: test
                  description: ""
                  type: CI
                  spec:
                    cloneCodebase: true
                    infrastructure:
                        type: KubernetesDirect
                        spec:
                            connectorRef: account.berkana
                            namespace: ci-build
                            automountServiceAccountToken: true
                            nodeSelector: {}
                            os: Linux
                    execution:
                        steps:
                        - step:
                            type: Run
                            name: Build
                            identifier: Build
                            spec:
                                connectorRef: account.dockerhuboccmundial
                                image: alpine
                                shell: Sh
                                command: echo "Hello OCC"
  EOT
}