/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  audit_log_config = {
    for key, val in var.audit_log_config :
    val.service => val...
  }
  project = (var.target_level == "project" || var.project != null || var.project != "" ?
    coalesce(var.project, var.target_id) : null)
}

resource "google_project_iam_audit_config" "project" {
  for_each = local.project != null ? local.audit_log_config : {}
  project  = var.target_id
  service  = each.key

  dynamic "audit_log_config" {
    for_each = each.value
    iterator = log_type
    content {
      log_type         = log_type.value.log_type
      exempted_members = log_type.value.exempted_members
    }
  }
}

resource "google_folder_iam_audit_config" "folder" {
  for_each = var.target_level == "folder" ? local.audit_log_config : {}
  folder   = var.target_id
  service  = each.key

  dynamic "audit_log_config" {
    for_each = each.value
    iterator = log_type
    content {
      log_type         = log_type.value.log_type
      exempted_members = log_type.value.exempted_members
    }
  }
}
resource "google_organization_iam_audit_config" "organization" {
  for_each = var.target_level == "org" ? local.audit_log_config : {}
  org_id   = var.target_id
  service  = each.key

  dynamic "audit_log_config" {
    for_each = each.value
    iterator = log_type
    content {
      log_type         = log_type.value.log_type
      exempted_members = log_type.value.exempted_members
    }
  }
}
