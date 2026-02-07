# RHCE Ansible Lab Infrastructure

This repository contains Terraform code to deploy a fully automated Red Hat Certified Engineer (RHCE) study lab on AWS. The infrastructure includes an Ansible Control Node and multiple Managed Nodes, networking, and dynamic storage.

## 📋 Account Prerequisites

Before starting, ensure you have the following:

1.  **AWS Account:** (Required) You need your own AWS account to host the infrastructure.
2.  **GitHub Account:** (Required) To fork this repository and push your changes.
3.  **Terraform Cloud Account:** (Optional)
    * **Required** if you want to use the automated GitHub Actions CI/CD pipeline.
    * **Not Required** if you plan to run Terraform locally from your laptop (Manual mode).

## 🏗 Architecture

* **Region:** Dynamic (Defaults to `us-east-1`, configurable).
* **Networking:**
    * 1 VPC with a Public Subnet.
    * Dynamic Availability Zone placement.
    * Security Groups allowing SSH (22) from your IP and internal traffic.
* **Compute:**
    * **Control Node:** `t3.medium` (2 vCPU, 4GB RAM) - RHEL 8.
    * **Managed Nodes:** 3x `t3.medium` (2 vCPU, 4GB RAM) - RHEL 8.
    * **Database Node:** 1x `t3.medium` (2 vCPU, 4GB RAM) with secondary storage.
* **Configuration:**
    * `cloud-init` automatically configures users (`hyfer`), SSH keys, and hostnames.
    * Internal DNS resolution via `hyfertechsolutions.com`.

## 🚀 CI/CD Workflow (GitHub Actions)

This project uses a **Dynamic Multi-User Workflow** to allow multiple team members to deploy their own isolated labs using a single repository.

### Branch Strategy

The workflow dynamically detects the **Branch Name** to determine where to deploy.

**Current Users:**
| Branch | TFC Org | Workspace | Auth Method |
| :--- | :--- | :--- | :--- |
| `main` | `Hyfer-Org` | `rhce-lab` | Prod Secret (Requires Approval) |
| `user/fre` | `frezdbanjhi` | `rhce-lab` | Environment Secret (`user/fre`) |
| `user/natasha`| `Hashiblack` | `rhce-lab` | Environment Secret (`user/natasha`) |
| `user/leslie` | `Leslie-Cloud-Org`| `rhce-lab` | Environment Secret (`user/leslie`) |
| `user/pat` | **Local** | **Local** | **Bypass TFC** (Local State) |

---

## 🛠 Setup Guide: Path A (Automated / CI/CD)
*For users utilizing Terraform Cloud and GitHub Actions (Fre, Natasha, Leslie, etc.)*

### 1. GitHub Configuration
1.  Create a branch matching your username (e.g., `user/fre`).
2.  Ensure a **GitHub Environment** exists with the exact same name (`user/fre`).
3.  **Security (Approvals):** Go to the Environment settings and enable **Required Reviewers**. Select yourself. This forces you to approve your own `apply` jobs.
4.  Add your Terraform Cloud API Token as a **Secret** in that environment named `TF_API_TOKEN`.

### 2. Terraform Cloud Configuration
Create a Workspace named `rhce-lab` and configure the following variables in the **Variables** tab:

| Variable | Type | Description |
| :--- | :--- | :--- |
| `AWS_ACCESS_KEY_ID` | Env | Your AWS Access Key. |
| `AWS_SECRET_ACCESS_KEY` | Env | Your AWS Secret Key. |
| `aws_region` | Terraform | Target Region (e.g., `us-east-1`). |
| `AWS_SSH_KEY` | Terraform | The **Name** of your AWS Key Pair. **(Must be ALL CAPS)** |
| `ssh_allowed_cidr` | Terraform | Your Public IP (e.g., `1.2.3.4/32`). |

### 3. Usage
1.  Push code to your branch: `git push origin user/fre`.
2.  GitHub Actions will trigger a **Plan**.
3.  Review the plan. If satisfied, the **Apply** job will trigger.
4.  **Approve:** Go to the workflow run and click **Review deployments** to approve the infrastructure changes.

---

## 🛠 Setup Guide: Path B (Local / Manual)
*For users running locally on their laptop (Pat)*

### 1. Local Prerequisites
1.  Install Terraform and AWS CLI locally.
2.  Configure AWS Credentials (`aws configure` or environment variables).

### 2. Configuration
Create a file named `terraform.tfvars` inside the `terraform/` directory.
*Note: This file is ignored by Git to protect your secrets.*

   ```# terraform/terraform.tfvars
   aws_region       = "us-east-2"
   AWS_SSH_KEY      = "my-local-aws-keypair-name"
   ssh_allowed_cidr = "x.x.x.x/32"
   ```

### 3. Usage
1.  Checkout your branch: `git checkout user/pat`.
2.  Run commands:

      ```bash
      cd terraform
      terraform init
      terraform apply
      ```

3.  The GitHub Action will automatically **skip** the TFC backend generation for the `user/pat` branch, preventing CI failures.

---

## 💻 Connecting to the Lab

1.  After the `apply` finishes, get the **Control Node Public IP** from the Terraform Output.
2.  SSH into the control node using your local key (User is `hyfer`):

      ```bash
      ssh -i /path/to/your-key.pem hyfer@<CONTROL_NODE_IP>
      ```

3.  **Verify Internal Access:** Switch to root and test connectivity to a managed node:

      ```bash
      sudo -i
      ssh ansible-node1
      ```

## 🧹 Cleanup

* **Automated Users:** Trigger the "Destroy" workflow manually from the GitHub Actions tab. (Requires Approval).
* **Local Users:** Run `terraform destroy`.