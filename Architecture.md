## Architecture - Components and Their Relationships
- AKS Public Load Balancer
- Ingress Controller
- Ingress Services
- Cert Manager
- External DNS
- DNS Zone
- AKS Internal Load Balancer
- API Gateway
- Service Discovery
- API Services
<br><br>
![Image](/doc-materials/images/prod-arch-01.png)

## Architecture - Services Relationships
![Image](/doc-materials/images/service-architecture.png)

## Architecture - Networking
- Kubernetes System Components installed on node pool 'system' which is the default node pool of AKS. They are labeled with 'app:system-apps'
- APIs deployed on 'user' node pool - labeled with 'app:api-apps'
- Database cluster deployed on a seperate 'user' node pool -  labeled with 'app:dbcluster-apps'
- Node pools of 'system-apps', 'api-apps' and 'dbcluster-apps' are isolated using sub networks
- AKS cluster management can be configured using the Jump Box rather than through the public networks

![Image](/doc-materials/images/prod-arch-02.png)



References:
- https://learn.microsoft.com/en-us/training/modules/aks-network-design-azure-container-network-interface/?source=recommendations
- https://learn.microsoft.com/en-us/azure/aks/operator-best-practices-network
- https://learn.microsoft.com/en-us/azure/aks/concepts-network
- https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni
- https://learn.microsoft.com/en-us/azure/aks/concepts-clusters-workloads#node-selectors