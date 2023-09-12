variable "app-namespace" {
  type        = string  
  default     = "asset-internal"
}

variable "asset-sc" {
  type        = string  
  default     = "asset-sc-internal"
}

variable "asset-pv" {
  type        = string  
  default     = "asset-pv-internal"
}

variable "zookeeper-nodeport" {
  type        = string  
  default     = "30183"
}

variable "rabbitmq-nodeport-http" {
  type        = string  
  default     = "31672"
}

variable "rabbitmq-nodeport-amqp" {
  type        = string  
  default     = "30672"
}

variable "zipkin-ingress-host" {
  type        = string  
  default     = "zipkin-int.samsassets.com"
}

variable "apigw-ingress-host" {
  type        = string  
  default     = "api-int.samsassets.com"
}

variable "security-ingress-host" {
  type        = string  
  default     = "auth-int.samsassets.com"
}

variable "image-version" {
  type        = string  
  default     = "2.5"
}

variable "users-dataSource-database" {
  type        = string  
  default     = "dGthaGlkYg=="
}

variable "users-dataSource-key" {
  type        = string  
  default     = "TTRWNXJXWHpBZFl2MFQzaDA2Y0JNSXQ0a0VmYlhNaTR2VWU0d2x4YjFUMlN0OTcybVA3YVpuOGNZcmV1ZkpWdG4wZXpCSHp4YWlsVEFDRGJJVDFQdWc9PQ=="
}

variable "users-dataSource-uri" {
  type        = string  
  default     = "aHR0cHM6Ly9haGktYmhhLWNvc21vcy1kZXYuZG9jdW1lbnRzLmF6dXJlLmNvbTo0NDMv"
}