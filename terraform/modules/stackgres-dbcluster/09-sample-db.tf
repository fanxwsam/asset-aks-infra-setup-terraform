
####################################  sample-db  #####################################
# sample-db db user secret
resource "kubernetes_secret" "sample_db_database_user" {
  metadata {
    name      = "sample-db-database-user"
    namespace = var.stagress_dbcluster_ns
  }

  data = {
    "create-user.sql" = "CREATE USER apiusersuser WITH PASSWORD 'apiusersuser@123'"
    username         = "apiusersuser"
    password         = "apiusersuser@123"
  }

  depends_on = [ kubernetes_namespace.postgres_db_clu_ns ]
}

# Credential for API
resource "kubernetes_secret" "sample_db_postgres" {
  metadata {
    name      = "sample-db-postgres"
    namespace = var.api_ns
  }

  data = {
    password = "apiusersuser@123"
  }

  depends_on = [ kubernetes_namespace.api_ns ]
}


# sample-db db initialization script
resource "kubernetes_config_map" "sample_db_database_init" {
  metadata {
    name      = "sample-db-database-init"
    namespace = var.stagress_dbcluster_ns
  }

  data = {
    "complete-generated-database-sample-db.sql" = file("${path.module}/sample-db-cluster/complete-generated-database-sample-db.sql")
  }
  depends_on = [ kubernetes_namespace.postgres_db_clu_ns ]
}


# 01-sample-db-pooler
data "kubectl_file_documents" "docs-01-sample-db-pooler" {
    content = file("${path.module}/sample-db-cluster/01-sample-db-pooler.yaml")
}

resource "kubectl_manifest" "_01-sample-db-pooler" {
  for_each  = data.kubectl_file_documents.docs-01-sample-db-pooler.manifests
  yaml_body = each.value
  depends_on = [kubernetes_secret.sample_db_database_user, kubernetes_secret.sample_db_postgres, kubernetes_config_map.sample_db_database_init, kubectl_manifest._04-postgres-14-config] 
}

# 02-sg-scripts-users
data "kubectl_file_documents" "docs-02-sg-scripts-users" {
    content = file("${path.module}/sample-db-cluster/02-sg-scripts-sample-db.yaml")
}

resource "kubectl_manifest" "_02-sg-scripts-users" {
  for_each  = data.kubectl_file_documents.docs-02-sg-scripts-users.manifests
  yaml_body = each.value  
  depends_on = [kubernetes_secret.sample_db_database_user, kubernetes_secret.sample_db_postgres, kubernetes_config_map.sample_db_database_init, kubectl_manifest._04-postgres-14-config] 
}

# 03-sample-db-sgcluster
data "kubectl_file_documents" "docs-03-sample-db-sgcluster" {
    content = file("${path.module}/sample-db-cluster/03-sample-db-sgcluster.yaml")
}

resource "kubectl_manifest" "_03-sample-db-sgcluster" {
  for_each  = data.kubectl_file_documents.docs-03-sample-db-sgcluster.manifests
  yaml_body = each.value
  depends_on = [kubectl_manifest._02-sg-scripts-users]
}