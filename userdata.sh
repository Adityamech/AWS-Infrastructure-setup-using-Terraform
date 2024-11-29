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
