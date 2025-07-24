
# CI/CD Pipeline for AKS using Terraform, Helm, and Azure DevOps

This repository contains a complete, end-to-end solution for deploying a containerized application to Azure Kubernetes Service (AKS). It uses **Terraform** for infrastructure provisioning, **Helm** for application packaging, and **Azure DevOps Pipelines** for CI/CD orchestration.

![Azure DevOps](https://img.shields.io/badge/Azure_DevOps-0078D7?style=for-the-badge&logo=azure-devops&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Helm](https://img.shields.io/badge/Helm-0F1689?style=for-the-badge&logo=helm&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)

---

## Core Concepts

This project demonstrates a repeatable and automated workflow for infrastructure and application deployment:

1.  **Infrastructure as Code (IaC):** **Terraform** is used to define and provision all necessary Azure resources, including the Virtual Network (VNet) and multiple AKS clusters representing different environments (dev, prod). This ensures the infrastructure is version-controlled and consistent.

2.  **Application Packaging:** **Helm** is used to package the Kubernetes manifests for the application. This allows for templating and managing application configurations for different environments from a single, version-controlled chart.

3.  **CI/CD Automation:** **Azure DevOps Pipelines** automates the entire process. When code is pushed to the repository, the pipeline automatically packages the Helm chart and deploys it sequentially across the dev and production environments, following a standard promotion model.

## Repository Structure

```
.
├── azure-pipelines.yml       # The main Azure DevOps pipeline definition.
├── helm/                     # The Helm chart for the application.
│   ├── Chart.yaml            # Chart metadata.
│   ├── values.yaml           # Default configuration values.
│   ├── values.dev.yaml       # Overrides for the 'dev' environment.
│   ├── values.prod.yaml      # Overrides for the 'prod' environment.
│   └── templates/            # Directory for Kubernetes manifest templates.
│       ├── deployment.yaml   # Defines the Kubernetes Deployment.
│       └── service.yaml      # Defines the Kubernetes Service.
└── terraform/                # The Terraform code for provisioning infrastructure.
    ├── main.tf               # Main entrypoint for infrastructure creation.
    ├── variables.tf          # Variable definitions.
    ├── terraform.tfvars      # (User-created) Variable values.
    └── modules/              # Reusable Terraform modules.
        ├── aks/              # Module for creating the AKS cluster.
        └── network/          # Module for creating the VNet.
```

---

## Getting Started: A Step-by-Step Guide

### Prerequisites

*   An **Azure Account** with permissions to create resources.
*   An **Azure DevOps Organization** and a new Project.
*   **Terraform CLI** (`~> 1.0`) installed locally.
*   **Azure CLI** installed locally (`az`).

### Step 1: Clone the Repository

Clone this repository to your local machine and navigate into the directory.

```bash
git clone <your-repo-url>
cd <your-repo-directory>
```

### Step 2: Provision the Infrastructure with Terraform

1.  **Navigate to the Terraform directory:**
    ```bash
    cd terraform
    ```

2.  **Create your variables file:**
    Create a file named `terraform.tfvars` and add the following content. Fill in the values for your specific setup.
    ```hcl
    # terraform/terraform.tfvars
    resource_group_name = "my-aks-project-rg"
    location            = "East US"
    prefix              = "myapp"
    ```

3.  **Log in to Azure and Initialize Terraform:**
    ```bash
    az login
    terraform init
    ```

4.  **Plan and Apply:**
    Review the plan and, if it looks correct, apply it to create the resources in Azure.
    ```bash
    terraform plan -out=tfplan
    terraform apply "tfplan"
    ```
    This will provision a VNet and three separate AKS clusters: `myapp-dev-aks` and `myapp-prod-aks`.

### Step 3: Configure Azure DevOps

1.  **Push the Code:**
    Push the contents of this repository to a new Git repository in your Azure DevOps project.

2.  **Create Service Connections:**
    You need to create a service connection for each AKS cluster so the pipeline can securely access them.
    *   In Azure DevOps, go to **Project Settings** > **Service connections**.
    *   Click **Create service connection**.
    *   Select **Kubernetes**.
    *   Choose **Kubeconfig** as the authentication method.
    *   Run the following Azure CLI command for *each* environment (`dev`,  `prod`) to get its kubeconfig, and paste the output into the service connection form.
        ```bash
        # Run for dev and prod
        az aks get-credentials --resource-group <your-resource-group-name> --name <cluster-name> --admin
        ```
    *   Name the service connections exactly as follows:
        *   `k8s-dev-connection`
        *   `k8s-prod-connection`

3.  **Create Variable Groups:**
    Variable groups are used to pass the service connection names to the correct pipeline stage.
    *   Go to **Pipelines** > **Library**.
    *   Create three new variable groups:
        *   **Name:** `my-app-dev` -> Add variable `KUBERNETES_SERVICE_CONNECTION` with value `k8s-dev-connection`.
        *   **Name:** `my-app-prod` -> Add variable `KUBERNETES_SERVICE_CONNECTION` with value `k8s-prod-connection`.
    *   In each variable group, ensure you grant pipeline permissions.

### Step 4: Create and Run the Pipeline

1.  **Create the Pipeline:**
    *   In Azure DevOps, go to **Pipelines** and click **Create Pipeline**.
    *   Select **Azure Repos Git** and choose your repository.
    *   Select **Existing Azure Pipelines YAML file**.
    *   Set the path to `/azure-pipelines.yml` and click **Continue**.

2.  **Run the Pipeline:**
    *   Click **Run**. You will see the parameters (`deployToDev`, `deployToProd`) in the run dialog.
    *   Leave the defaults and run the pipeline.

The pipeline will now execute. It will build the Helm chart and then deploy it sequentially to your dev and production environments.

