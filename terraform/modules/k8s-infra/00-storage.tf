# The cluster will use 2 different storage class
# cstor-mirror is for the database and some other components: azure-disk
# efs is for file system - file upload: azure-file

data "kubectl_file_documents" "docs_storage_cstor" {
    content = file("${path.module}/00-storage/01-storage-class-aks-cstor-mirror.yml")
}

data "kubectl_file_documents" "docs_storage_efs" {
    content = file("${path.module}/00-storage/02-efs-storage-class.yaml")
}

resource "kubectl_manifest" "storage_cstor" {
    for_each  = data.kubectl_file_documents.docs_storage_cstor.manifests
    yaml_body = each.value 
}

resource "kubectl_manifest" "storage_efs" {
    for_each  = data.kubectl_file_documents.docs_storage_efs.manifests
    yaml_body = each.value
    depends_on = [kubectl_manifest.storage_cstor]
}