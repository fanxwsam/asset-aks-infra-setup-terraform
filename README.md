## Description of the Azure Kubernetes Deployment Environment
1. Each AKS cluster will be created with 3 nodes by default across 3 subnets
   - system
   - application
   - database   
2. Guidance for setup steps
   - Manually: Prerequisite configuration(e.g. DNS, sshkey, terraform state storage)
   - Terraform: Deploy aks cluster
   - Manually:  Deploy components - 'Linkerd'. (Using terraform has issues) 
   - Terraform: Deploy basic components(Ingress, Dashboard, ExternalDNS, Cert Manager, DB cluster Operator...) on AKS
   - Terraform: Deploy database cluster on AKS
   - Terraform: Deploy applications(APIGW, RabbitMQ, Kafka, Authorization Server), APIs (customers, fraud, notifications, messages and users)
3. Components deployed
   - Ingress Nginx
   - Linkerd
   - ExternalDNS
   - Cert Manager
   - Metrics Dashboard
   - Prometheus
   - Grafana
   - Stackgres for Postgres DB Cluster
4. Applications/APIs deployed
   - RabbitMQ
   - Zookeeper
   - Kafka
   - Postgres
   - Eureka
   - Zipkin
   - APIGW
   - api-security (the Authorization Server)
   - api-customers
   - api-fraud
   - api-notifications
   - api-messages
   - api-users

5. Terraform script include 2 environment deployment
   - devuat (internal): folder 'terraform/01*-05*'
   - prod (external): folder 'terraform/91*-95*'


## AKS Cluster  Installation Details
1. Create terraform state storage 
   - Create a resource group named 'terraform-storage-rg'
   - Create a storage accounts named 'tfstateassetenv' in resource group 'terraform-storage-rg'
   - Create a container named 'tfstatefiles' in storage accounts 'tfstateassetenv'

2. Create SSH Keys for AKS Linux VMs<br>
   refer to document: doc-materials/ssh-public-key.md

3. Add Public DNS Zone in resource group '**dns-zone**' using Azure Portal. 
   - samsassets.com
   - kubedev.link
 <br>Domain provider needs to make the corresponding changes for the name servers that you use when you 
   create the DNS Zone  <br>

   - Refer to documents: <br>
     - **/asset-aks-infra-setup-manually/01-cluster/04-Aure-DNS-Zone-Delegate/README.md** <br>
     - https://learn.microsoft.com/en-us/azure/dns/dns-getstarted-portal <br>
     - https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/migrate-dns-domain-in-use.html <br>


4. Create AKS cluster
   - 'internal' means the dev&uat envirornment (internal use), and 'external' is for 'public' (expose outside)
   - Declare Windows Username, Passwords for Windows nodepools. This needs to be done during the creation of cluster for 1st time itself if you have plans for Windows workloads on your cluster
   - Data sources and Create data source for Azure AKS latest Version
   - Create Azure Log Analytics Workspace Resource
   - Create Azure AD AKS Admins Group Resource
   - Create AKS Cluster with default nodepool
   - Create AKS Cluster costomized user nodepool
   - Assign proper roles for different components
   - Create AKS Cluster Output Values

```
az login --tenant THE_TENANT_ID
cd 01-cloud-infra-internal
terraform init
terraform plan
terraform apply
```

5. Install Linkerd manually <br> 
   run the commands in file '/terraform/02-install-manually-internal/README.md'

   (Linkerd is not easy to installed using terraform and there are some problems. But it's very easy to install manually)

6. Deploy components in AKS cluster
   - linkerd (deployed in step 5 manually)
   - storage
   - cert-manager
   - external-dns
   - ingress-nginx
   - dashboard
   - prometheus-grafana
   - stackgress-operator

   ```
   cd 03-k8s-infra-internal
   terraform init
   terraform apply
   ```
<br>

7. Deploy database clusters
   - sample-db-cluster

   !!!IMPORTANT:
   Change the value of variable 'storage_account_name' in file '/04-stackgres-db-clu-internal/main.tf'
   The storage_account_name should be the one created in '01-cloud-infra-internal', and the value includes 'Random' String (because the Azure Storage Account Name must be globally unique)

   ```
   cd 04-stackgres-db-clu-internal
   terraform init
   terraform apply
   ```
   Verify the database cluster creation
   ```
   kubectl -n postgres-db-clu exec -ti sample-db-0 -c postgres-util -- psql
   \l
   \c apiusers
   \d
   ```
<br>

8. Deploy Applications/APIs
   - RabbitMQ
   - Zookeeper
   - Kafka
   - Postgres
   - Eureka
   - Zipkin
   - APIGW
   - api-security (the Authorization Server)
   - api-customers
   - api-fraud
   - api-notifications
   - api-messages
   - api-users

```
cd 05-api-deployment-internal
terraform init
terraform apply
```
<br>
NOTE: <br>
Folders 91-XX - 95-XX are for another AKS Cluster 'external'. Please repeat 8 steps above to create a brand-new AKS cluster 'external'. <br>
You can change the parameters in 'main.tf' files of each step to create the customized AKS clusters.


<br><br>
## Connect to cluster
```
az aks get-credentials -g aks-internal-rg -n aks-internal-cluster --overwrite-existing --admin
az aks get-credentials -g aks-external-rg -n aks-external-cluster --overwrite-existing --admin
```
<br>

## Get Kubernetes Dashboard Token:
kubectl describe secret aks-admin-token -n kube-system
<br><br>

## Links of Internal AKS Cluster
### APIs

<https://api-int.samsassets.com/swagger-ui.html>
<br>

<https://api-int.samsassets.com>
<br>

<https://auth-int.samsassets.com>
<br>

### Dashboard
<https://dashboard.samsassets.com/dashboard> 
<br>
(token:   kubectl describe secret aks-admin-token -n kube-system)
<br>

### Linkerd VIZ
<https://linkerd.samsassets.com><br>
- username: admin
- password: admin
<br>

### Grafana
<https://grafana.samsassets.com><br>
- username: admin
- password: p@sSw0rd$1%-#1
https://grafana.samsassets.com/d/09ec8aa1e996d6ffcd6817bbaff4db1b/kubernetes-api-server?orgId=1&refresh=10s&from=1694506777672&to=1694510377672
<br>

### Dev & UAT Database Cluster Management
<https://stackgres.samsassets.com/><br>
- username: admin
- password: 43Ts7e5bXu3SrcTsbfAoKi7POgJdEjTJDjoDpWGP
<br>

### Zipkin
<https://zipkin-int.samsassets.com>
<br>

### Dev & UAT Monitoring - Prometheus
This link can only be accessed in the virtual network because there is no password protection. Please use the Jump Box '20.53.207.135' <br>
<https://prometheus.samsassets.com><br>
<br>