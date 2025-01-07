# Terraform-AWS-Project

In This Terraform AWS project! I automated AWS infrastructure using Terraform to deploy two applications in different availability zones, set up a VPC, and configure a load balancer to handle traffic seamlessly.


![Alt text](Assets/TerraformInfrastructureDiagram.png)


WE USED TERRAFORM TO:

- **Create a Virtual Private Cloud (VPC) with subnets in different availability zones.**
- **Deploy two EC2 instances, each in a separate subnet.**
- **Automating S3 Bucket Creation with Terraform**
- **Set up a load balancer to distribute traffic between these instances automatically.**

  "With Terraform, infrastructure as code allows us to provision resources consistently and efficiently."

### ***Step 1: Setting Up a Virtual Machine (VM) to Run Terraform***
First we need a reliable environment to execute Terraform commands. I accomplished this by provisioning an EC2 instance with the following configuration:
- Instance Type: t2.medium (2 vCPUs, 4 GiB memory)
- Storage: 15 GiB of gp3 SSD
  
![Screenshot 2024-11-29 142406](https://github.com/user-attachments/assets/eb6b4075-452c-4e29-8fd7-7cc39dc74846)

Once the EC2 instance was up and running, I performed the following steps:
#### 1. Updated the System and Installed AWS CLI and Terraform on the Machine.
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
- Official Documentation of AWS: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- Official Documentation of Terraform: https://developer.hashicorp.com/terraform/install
#### 2. Created an IAM User with necessary permissions and generated access keys.
![Screenshot 2024-11-29 142535](https://github.com/user-attachments/assets/b96725e4-7677-4796-90e2-58f011e6186a)
![Screenshot 2024-11-29 142605](https://github.com/user-attachments/assets/ab59d9f8-e7b1-430b-a64b-7f13ca79b397)

#### 3. Configured AWS CLI with the access key, secret key, and region to enable secure access to AWS services for Terraform.
Finally, I configured the AWS CLI on the EC2 instance with the newly created access credentials:
``` shell
aws configure
```
![Screenshot 2024-11-29 143311](https://github.com/user-attachments/assets/61a3887d-2928-4b93-9fee-0a8c4f64416c)

### ***Step 2: Write "Provider.tf" configuration to define the provider***
In This provider.tf file is essential for connecting Terraform to AWS and managing infrastructure in the specified region.
- terraform Block
``` shell
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.11.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```
terraform Block:
Specifies the AWS provider (hashicorp/aws) and locks its version to 5.11.0 to ensure compatibility.

provider "aws" Block:
Configures the AWS provider to deploy resources in the us-east-1 region.

- provider.tf is typically the first file Terraform reads to know which provider to use and where to deploy resources.
- Once this configuration is in place, other Terraform files (main.tf, variables.tf, etc.) can define the actual AWS infrastructure (like VPCs, subnets, EC2 instances, etc.).

### ***Step 3: Write "main.tf" configuration to creates an AWS infrastructure with Terraform***
main.tf configuration to creates an AWS infrastructure with Terraform, including a VPC, subnets, EC2 instances, an internet gateway, a security group, a load balancer, and other resources necessary for a web application deployment.
#### 1. Create a Virtual Private Cloud (VPC)
``` shell
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}
```
- aws_vpc resource creates a VPC.
- CIDR Block: The IP address range of the VPC is defined by the variable var.cidr.
#### 2. Create Subnets in Different Availability Zones
``` shell
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}
```
``` shell
resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}
```
- Resource: aws_subnet creates two subnets within the VPC.
- CIDR Blocks: Each subnet is assigned a different IP range.
- Availability Zones: sub1 is in us-east-1a, and sub2 is in us-east-1b.
- Public IP: map_public_ip_on_launch is set to true, making instances launched in these subnets accessible from the internet.

#### 3. Create an Internet Gateway
``` shell
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}
```
- Resource: aws_internet_gateway attaches an internet gateway to the VPC, allowing instances to access the internet.

#### 4. Create a Route Table and Associate It with Subnets
``` shell
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
```
- Route Table: Defines a route to forward all internet traffic (0.0.0.0/0) to the internet gateway.

``` shell
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.rt.id
}
```
- Associations: Link the route table to both subnets.

#### 5. Create a Security Group for Web Servers
``` shell
resource "aws_security_group" "webSg" {
  name   = "web"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```
- Ingress Rules:
  Allow HTTP traffic on port 80 from anywhere (0.0.0.0/0).
  Allow SSH access on port 22 from anywhere.
- Egress Rules: Allow all outbound traffic.

#### 6. Automating S3 Bucket Creation with Terraform
``` shell
resource "aws_s3_bucket" "example" {
  bucket = "my-terraform-project"
}
```
- resource "aws_s3_bucket" "example": This declares a new AWS S3 bucket resource named example.
- bucket = "my-first-terraform-project": Specifies the name of the S3 bucket.
  
#### 7. Launch Two EC2 Instances in Different Subnets
``` shell
resource "aws_instance" "webserver1" {
  ami                    = "ami-0866a3c8686eaeeba"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.sub1.id
  user_data              = base64encode(file("userdata.sh"))
}
```
``` shell
resource "aws_instance" "webserver2" {
  ami                    = "ami-0866a3c8686eaeeba"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.sub2.id
  user_data              = base64encode(file("userdata1.sh"))
}
```
- AMI: Amazon Machine Image for the instance.
- Instance Type: t2.micro (free-tier eligible).
- User Data: Custom startup script for each instance.

#### 8. Create an Application Load Balancer (ALB)
``` shell
resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webSg.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]
}
```
- Resource: aws_lb creates an ALB to balance traffic between the two instances.

#### 9. Create a Target Group and Attach Instances
``` shell
resource "aws_lb_target_group" "tg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}
```
``` shell
resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}
```
- Target Group: Manages the EC2 instances behind the load balancer.
- Attachments: Connects each instance to the target group.
#### 10. Create a Listener for the Load Balancer
``` shell
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}
```
- Listener: Listens for incoming HTTP traffic on port 80 and forwards it to the target group.

#### 11. Output the Load Balancer DNS
``` shell
output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
}
```
- Output: Displays the DNS name of the load balancer after deployment, allowing you to access the application.

### ***Step 4: Write "variables.tf" configuration to defining the VPC CIDR Block***
This step highlights that the CIDR block for the VPC is being defined as a variable (cidr), allowing flexibility and reusability across different environments or configurations. By setting the default value to 10.0.0.0/16, you're specifying the range of IP addresses available for the VPC.
``` shell
variable "cidr" {
  default = "10.0.0.0/16"
}
```
- variable "cidr": Declares a variable named cidr.
- default = "10.0.0.0/16":
-- Specifies a default value for the variable if no other value is provided. 
-- In this case, the default CIDR block for the VPC is 10.0.0.0/16.  
-- The /16 subnet mask allows for 65,536 IP addresses (from 10.0.0.0 to 10.0.255.255).  

### ***Step 5: Use Shell Script file to Configure and Deploy Application on EC2***
EC2 Instance 1: userdata.sh
``` shell
#!/bin/bash
# Update the system and install Apache2
apt update && apt install -y apache2

# Get the instance ID using instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Install AWS CLI for potential future use
apt install -y awscli

# (Optional) Download images from an S3 bucket
#aws s3 cp s3://myterraformprojectbucket2023/project.webp /var/www/html/project.png --acl public-read

# Create a modern, styled HTML page for the portfolio content
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Aditya's Portfolio - Terraform Project</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #2c3e50;
      color: #ecf0f1;
      margin: 0;
      padding: 0;
    }

    header {
      background-color: #34495e;
      padding: 20px;
      text-align: center;
    }

    header h1 {
      font-size: 2.5em;
      color: #e74c3c;
      animation: colorChange 3s infinite;
    }

    header h2 {
      font-size: 1.5em;
      margin-top: 10px;
    }

    p {
      text-align: center;
      font-size: 1.2em;
      margin-top: 20px;
      color: #bdc3c7;
    }

    .instance-id {
      color: #2ecc71;
      font-weight: bold;
    }

    @keyframes colorChange {
      0% { color: #e74c3c; }
      50% { color: #f39c12; }
      100% { color: #8e44ad; }
    }
  </style>
</head>
<body>
  <header>
    <h1>Terraform Project Server 1</h1>
    <h2>Instance ID: <span class="instance-id">${INSTANCE_ID}</span></h2>
  </header>
  <p>Welcome to Aditya's Terraform Project 1</p>
</body>
</html>
EOF

# Start Apache2 and enable it to run on boot
systemctl start apache2
systemctl enable apache2

```

EC2 Instance 2: userdata1.sh
``` shell
#!/bin/bash
# Update the system and install Apache2
apt update && apt install -y apache2

# Get the instance ID using instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Install AWS CLI for potential future use
apt install -y awscli

# (Optional) Download images from an S3 bucket
#aws s3 cp s3://myterraformprojectbucket2023/project.webp /var/www/html/project.png --acl public-read

# Create a modern, styled HTML page for the portfolio content
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Aditya's Portfolio - Terraform Project</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #2c3e50;
      color: #ecf0f1;
      margin: 0;
      padding: 0;
    }

    header {
      background-color: #34495e;
      padding: 20px;
      text-align: center;
    }

    header h1 {
      font-size: 2.5em;
      color: #e74c3c;
      animation: colorChange 3s infinite;
    }

    header h2 {
      font-size: 1.5em;
      margin-top: 10px;
    }

    p {
      text-align: center;
      font-size: 1.2em;
      margin-top: 20px;
      color: #bdc3c7;
    }

    .instance-id {
      color: #2ecc71;
      font-weight: bold;
    }

    @keyframes colorChange {
      0% { color: #e74c3c; }
      50% { color: #f39c12; }
      100% { color: #8e44ad; }
    }
  </style>
</head>
<body>
  <header>
    <h1>Terraform Project Server 2</h1>
    <h2>Instance ID: <span class="instance-id">${INSTANCE_ID}</span></h2>
  </header>
  <p>Welcome to Aditya's Terraform Project 2</p>
</body>
</html>
EOF

# Start Apache2 and enable it to run on boot
systemctl start apache2
systemctl enable apache2

```

Overview: 
- Launch EC2 Instance.
- User Data Script Runs:
Installs Apache and AWS CLI.
Fetches the EC2 Instance ID.
Creates a custom HTML file displaying the instance details.
Starts the Apache server.
- Access the Web Page:
The web page can be accessed through ALB DNS name on web browser (http://<public-ip>).

### ***Step 6: Run Terraform Commands***
Throughout the project, I followed Terraform best practices:
-  ***terraform init*** to initializes the working directory and downloads the necessary provider plugins.
![Screenshot 2024-11-29 203002](https://github.com/user-attachments/assets/336c5ab1-d695-422b-9241-466748d33802)

-  Used the ***terraform validate*** command to check for syntax errors.
![Screenshot 2024-11-29 203039](https://github.com/user-attachments/assets/e0458cb8-44f0-4744-bdc5-b268f0169d40)

- Ran ***terraform fmt*** to format the code for readability.
- And executed ***terraform plan*** to preview the resources before applying changes.
![Screenshot 2024-11-29 203149](https://github.com/user-attachments/assets/2ff19cb7-4d53-44ec-958f-1940aeb0c24e)
![Screenshot 2024-11-29 203216](https://github.com/user-attachments/assets/bbce336c-66d8-4256-9638-444ff8665759)

- Finally, ***terraform apply*** to actually execute resources:
![Screenshot 2024-11-29 203315](https://github.com/user-attachments/assets/ec0cbc78-0110-4f42-bd24-49716a34abaa)
![Screenshot 2024-11-29 203429](https://github.com/user-attachments/assets/54e61024-f2ee-4f65-880f-931a53b05a22)

### Outputs:
Web view:
![Screenshot 2024-11-29 212322](https://github.com/user-attachments/assets/04f663eb-cfb3-4e22-91d0-3de769fe113b)
![Screenshot 2024-11-29 212345](https://github.com/user-attachments/assets/ac6fac69-b02b-4c4c-bef4-87fd6a47e22b)


On AWS :
![Screenshot 2024-11-26 005636](https://github.com/user-attachments/assets/11c09c50-542f-4a60-aed8-87aabdcc4f50)
![Screenshot 2024-11-25 220644](https://github.com/user-attachments/assets/7e0ddf5d-bba0-401c-89ff-585b9a1af6fb)
![Screenshot 2024-11-25 220634](https://github.com/user-attachments/assets/d1e476f7-719e-4872-9514-82d3028e1798)
![Screenshot 2024-11-25 220622](https://github.com/user-attachments/assets/f1c6221a-ec58-4e6a-96ba-04c9bddb3558)
![Screenshot 2024-11-29 204837](https://github.com/user-attachments/assets/276597ca-ae1a-4c79-99ac-ce8ed94985cf)
![Screenshot 2024-11-26 005746](https://github.com/user-attachments/assets/d64fad6e-4551-4c6b-9fd3-3067dbf73585)
![Screenshot 2024-11-26 005516](https://github.com/user-attachments/assets/b9fa182c-bf9e-4fde-84e8-2cde8aba74ef)
![Screenshot 2024-11-26 005220](https://github.com/user-attachments/assets/51a03ecd-14d5-422c-b251-a8eb638684f7)
![Screenshot 2024-11-29 204949](https://github.com/user-attachments/assets/22eadc4f-c678-48c4-9575-2f6897305e2b)
![Screenshot 2024-11-26 000214](https://github.com/user-attachments/assets/9cfdb072-7f64-451a-a37d-6d2f27a61088)

### Destroy the Infrastructure using command:
``` shell
terraform destroy
```
![Screenshot 2024-11-29 211853](https://github.com/user-attachments/assets/0608d917-dbad-4da5-aea1-ef0238370c4f)
![Screenshot 2024-11-29 211903](https://github.com/user-attachments/assets/3f05fe74-0386-4d1a-83aa-f6648d343e7b)

