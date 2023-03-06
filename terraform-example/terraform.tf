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
  name = "harness-demo-ci"
  identifier = "harness_demo_ci"
  org_id = "default"
  project_id = "default_project"
  template_applied = true
  git_details {
    branch_name = "main"
    commit_message = "ci: Created pipeline in harness"
    file_path = ".harness/harness_demo_ci_2.yaml"
    connector_ref = "account.ghdevopsocc"
    store_type = "REMOTE"
    repo_name = "harness-demo-ci"
  }
  yaml = <<-EOT
      pipeline:
          name: harness-demo-ci
          identifier: harness_demo_ci
          template:
              templateRef: account.NodeJS_Template
              templateInputs:
                  properties:
                      ci:
                          codebase:
                              repoName: <+input>
                              build: <+input>
          tags: {}
          projectIdentifier: default_project
          orgIdentifier: default
  EOT
}