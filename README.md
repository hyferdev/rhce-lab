# RHCE Ansible Lab Infrastructure

This repository contains Terraform code to deploy a fully automated Red Hat Certified Engineer (RHCE) study lab on AWS. The infrastructure includes an Ansible Control Node and multiple Managed Nodes, networking, and dynamic storage.

## 🏗 Architecture

* **Region:** Dynamic (Defaults to `us-east-1`, configurable via TFC/tfvars).
* **Networking:**
    * 1 VPC with a Public Subnet.
    * Dynamic Availability Zone placement (automatically selects available zones).
    * Security Groups allowing SSH (22) from your IP and internal traffic.
* **Compute:**
    * **Control Node:** `t3.medium` (2 vCPU, 4GB RAM) - RHEL 8.
    * **Managed Nodes:** 3x `t3.medium` (2 vCPU, 4GB RAM) - RHEL 8.
    * **Database Node:** 1x `t3.medium` (2 vCPU, 4GB RAM) with a secondary EBS volume attached.
* **Configuration:**
    * `cloud-init` automatically configures users (`hyfer`), SSH keys, and hostnames.
    * Internal DNS resolution via `hyfertechsolutions.com`.

## 🚀 CI/CD Workflow (GitHub Actions)

This project uses a **Dynamic Multi-User Workflow** to allow multiple team members to deploy their own isolated labs using a single repository.

### How it works
The `.github/workflows/terraform.yml` pipeline dynamically detects the **Branch Name** and selects the corresponding **Terraform Cloud Workspace** and **Authentication Token**.

| Branch | TFC Org | Workspace | Auth Method |
| :--- | :--- | :--- | :--- |
| `main` | `Hyfer-Org` | `rhce-lab` | Prod Secret (Requires Approval) |
| `user/fre` | `frezdbanjhi` | `rhce-lab` | Environment Secret (`user/fre`) |
| `user/natasha`| `Hashiblack` | `rhce-lab` | Environment Secret (`user/natasha`) |
| `user/leslie` | `Leslie-Cloud-Org`| `rhce-lab` | Environment Secret (`user/leslie`) |
| `user/pat` | **Local** | **Local** | **Bypass TFC** (Local State) |

## 🛠 Setup Guide

### 1. Automated Users (Fre, Natasha, Leslie, etc.)
**Prerequisites:**
1.  Create a branch matching your username (e.g., `user/fre`).
2.  Ensure a **GitHub Environment** exists with the exact same name (`user/fre`).
3.  Add your Terraform Cloud API Token as a **Secret** in that environment named `TF_API_TOKEN`.
4.  Set the `aws_region` variable in your **Terraform Cloud Workspace**.

**Usage:**
1.  Push code to your branch: `git push origin user/fre`.
2.  GitHub Actions will trigger a **Terraform Plan**.
3.  Review the plan in the Pull Request or Action logs.
4.  If satisfied, the Apply will run (or wait for approval if configured).

### 2. Local Users (Pat)
**Prerequisites:**
1.  Install Terraform and AWS CLI locally.
2.  Configure AWS Credentials (`aws configure` or env vars).

**Configuration:**
Create a `terraform.tfvars` file in the `terraform/` directory (this is ignored by git):

```hcl
# terraform/terraform.tfvars
aws_region   = "us-east-2"
AWS_SSH_KEY  = "my-local-aws-keypair-name"
ssh_allowed_cidr = "x.x.x.x/32"
```

**Usage:**
1.  Checkout your branch: `git checkout user/pat`.
2.  Run locally:
    ```bash
    cd terraform
    terraform init
    terraform apply
    ```
3.  The GitHub Action will automatically **skip** the TFC backend generation for the `user/pat` branch, preventing CI failures.

## 🔐 Security & Secrets

* **Authentication:** TFC Tokens are injected via **GitHub Environments**. This ensures User A cannot access User B's token.
* **Approvals:** The `main` branch (Production) requires manual approval from an Admin before `terraform apply` runs.
* **SSH Keys:** The lab automatically generates an internal RSA key pair for Ansible communication between nodes. The private key is injected into `/root/.ssh/id_rsa` on the Control Node.

## 🧹 Cleanup

* **Automated:** Trigger the "Destroy" workflow manually from the GitHub Actions tab.
* **Local:** Run `terraform destroy`.