# Terraform-AWS-Project

In This Terraform AWS project! I automated AWS infrastructure using Terraform to deploy two applications in different availability zones, set up a VPC, and configure a load balancer to handle traffic seamlessly.


![Alt text](Assets/TerraformInfrastructureDiagram.png)


WE USED TERRAFORM TO:

- **Create a Virtual Private Cloud (VPC) with subnets in different availability zones.**
- **Deploy two EC2 instances, each in a separate subnet.**
- **Set Up a Remote Backend with an S3 Bucket for Seamless State Management**
- **Set up a load balancer to distribute traffic between these instances automatically.**

  "With Terraform, infrastructure as code allows us to provision resources consistently and efficiently."

### Step 1: Setting Up a Virtual Machine (VM) to Run Terraform
First we need a reliable environment to execute Terraform commands. I accomplished this by provisioning an EC2 instance with the following configuration:
- Instance Type: t2.medium (2 vCPUs, 4 GiB memory)
- Storage: 15 GiB of gp3 SSD
Once the EC2 instance was up and running, I performed the following steps:
##### 1. Updated the system and installed AWS CLI.
Official Documentation: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
``` shell
sudo apt update && sudo apt upgrade -y

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```
##### 2. Created an IAM User with necessary permissions and generated access keys.***
##### 3. Configured AWS CLI with the access key, secret key, and region to enable secure access to AWS services for Terraform.***




