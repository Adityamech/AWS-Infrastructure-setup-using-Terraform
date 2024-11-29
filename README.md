# Terraform-AWS-Project

In This Terraform AWS project! I automated AWS infrastructure using Terraform to deploy two applications in different availability zones, set up a VPC, and configure a load balancer to handle traffic seamlessly.


![Alt text](Assets/TerraformInfrastructureDiagram.png)


WE USED TERRAFORM TO:

- **Create a Virtual Private Cloud (VPC) with subnets in different availability zones.**
- **Deploy two EC2 instances, each in a separate subnet.**
- **Set Up a Remote Backend with an S3 Bucket for Seamless State Management**
- **Set up a load balancer to distribute traffic between these instances automatically.**

  "With Terraform, infrastructure as code allows us to provision resources consistently and efficiently."

### ***Step 1: Setting Up a Virtual Machine (VM) to Run Terraform***
First we need a reliable environment to execute Terraform commands. I accomplished this by provisioning an EC2 instance with the following configuration:
- Instance Type: t2.medium (2 vCPUs, 4 GiB memory)
- Storage: 15 GiB of gp3 SSD
  
![Screenshot 2024-11-29 142406](https://github.com/user-attachments/assets/eb6b4075-452c-4e29-8fd7-7cc39dc74846)

Once the EC2 instance was up and running, I performed the following steps:
##### 1. Updated the System and Installed AWS CLI and Terraform on the Machine.
``` shell
sudo apt update && sudo apt upgrade -y

# aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# install Terraform
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```
Official Documentation of AWS: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
Official Documentation of Terraform: https://developer.hashicorp.com/terraform/install
##### 2. Created an IAM User with necessary permissions and generated access keys.
![Screenshot 2024-11-29 142535](https://github.com/user-attachments/assets/b96725e4-7677-4796-90e2-58f011e6186a)
![Screenshot 2024-11-29 142605](https://github.com/user-attachments/assets/ab59d9f8-e7b1-430b-a64b-7f13ca79b397)

##### 3. Configured AWS CLI with the access key, secret key, and region to enable secure access to AWS services for Terraform.
Finally, I configured the AWS CLI on the EC2 instance with the newly created access credentials:
``` shell
aws configure
```
![Screenshot 2024-11-29 143311](https://github.com/user-attachments/assets/61a3887d-2928-4b93-9fee-0a8c4f64416c)









