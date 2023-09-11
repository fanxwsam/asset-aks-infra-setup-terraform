variable "stagress_dbcluster_ns" {
  type        = string  
  default     = "postgres-db-clu"
}

variable "api_ns" {
  type        = string  
  default     = "asset-api"
}


variable "environment" {
    type = string
    description = "This is the variable that define the Environmen"
    default = "external"
}

variable "storage_account_rg" {
    type = string
    description = "Azure storage account resource group name for data backup"
    default = "data-backup-external-rg"
}

variable "storage_account_name" {
    type = string
    description = "Azure storage account name for data backup"
    default = "databackexternal"
}