# create namespace for postgres cluster
resource "kubernetes_namespace" "postgres_db_clu_ns" { 
  metadata {
    name = var.stagress_dbcluster_ns
  }
}

# create namespace for APIs
resource "kubernetes_namespace" "api_ns" { 
  metadata {
    name        = var.api_ns
  }
}

data "azurerm_storage_account" "data_backup_storage_acount" {
  name = var.storage_account_name
  resource_group_name = var.storage_account_rg
}

# create secrete to handle the backup storage account password
resource "kubernetes_secret" "azure_blob_storage_creds" {
  metadata {
    name = "azure-blob-storage-creds"
    namespace = var.stagress_dbcluster_ns
  }

  data = {
    "storage-account" = base64encode(data.azurerm_storage_account.data_backup_storage_acount.name)
    "access-key" = base64encode(data.azurerm_storage_account.data_backup_storage_acount.primary_access_key)
  }
  depends_on = [ kubernetes_namespace.postgres_db_clu_ns ]
}

# stackgres database cluster basic configurations like instance profile, backup storage and postgress versions and extensions
# resource "kubernetes_manifest" "public_config" {
#   for_each = fileset("${path.module}/public-config/", "*.yml")
#   manifest = yamldecode(file("${path.module}/public-config/${each.value}"))
#   depends_on = [kubernetes_namespace.postgres_db_clu_ns, kubernetes_secret.azure_blob_storage_creds]
# }


# 01-sg-instance-profile
data "kubectl_file_documents" "docs-01-sg-instance-profile" {
    content = file("${path.module}/public-config/01-sg-instance-profile.yml")
}


resource "kubectl_manifest" "_01-sg-instance-profile" {
  for_each  = data.kubectl_file_documents.docs-01-sg-instance-profile.manifests
  yaml_body = each.value
  depends_on = [kubernetes_namespace.postgres_db_clu_ns, kubernetes_secret.azure_blob_storage_creds] 
}

# 03-backup-config
data "kubectl_file_documents" "docs-03-backup-config" {
    content = file("${path.module}/public-config/03-backup-config.yml")
}

resource "kubectl_manifest" "_03-backup-config" {
  for_each  = data.kubectl_file_documents.docs-03-backup-config.manifests
  yaml_body = each.value
  depends_on = [kubernetes_namespace.postgres_db_clu_ns, kubernetes_secret.azure_blob_storage_creds] 
}

# 04-postgres-14-config
data "kubectl_file_documents" "docs-04-postgres-14-config" {
    content = file("${path.module}/public-config/04-postgres-14-config.yml")
}

resource "kubectl_manifest" "_04-postgres-14-config" {
  for_each  = data.kubectl_file_documents.docs-04-postgres-14-config.manifests
  yaml_body = each.value
  depends_on = [kubernetes_namespace.postgres_db_clu_ns, kubernetes_secret.azure_blob_storage_creds, kubectl_manifest._01-sg-instance-profile, kubectl_manifest._03-backup-config]
}