variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro" # Changed from t3.xlarge to remain Free Tier friendly
}
variable "use_custom_ami" {
  type        = bool
  default     = true
  description = "Flag to determine whether to build incrementally from last month's AMI or start fresh from base."
}

locals {
  timestamp       = formatdate("YYYYMM", timestamp())
  build_timestamp = formatdate("YYYYMMDD-hhmm", timestamp())
  ami_name        = "Enlyte-Authorized-AMI-Win2025-${local.timestamp}-${local.build_timestamp}"
}

source "amazon-ebs" "windows_buildami" {
  region         = var.aws_region
  instance_type  = var.instance_type
  communicator   = "winrm"
  winrm_username = "Administrator"
  winrm_insecure = true
  winrm_use_ssl  = false
  winrm_timeout  = "45m"

 source_ami_filter {
    filters = {
      name                = var.use_custom_ami ? "Enlyte-Authorized-AMI-Win2025-*" : "Windows_Server-2025-English-Full-Base-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = var.use_custom_ami ? ["self"] : ["801119661308"]
  }

  ami_name = local.ami_name

  # Root Volume Settings (30GB fits within Free Tier limit)
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 30 # Reduced from 100GB to avoid EBS charges
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name       = local.ami_name
    OS_Version = "Windows Server 2025"
    Created_By = "Packer-Ansible-Pipeline"
  }
}

build {
  sources = ["source.amazon-ebs.windows_buildami"]

  # 1. Provision using Ansible
  provisioner "ansible" {
    playbook_file    = "./provisioners/ansible/playbook.yml"
    galaxy_file      = "./provisioners/ansible/requirements.yml"
    use_proxy        = false
    user             = "Administrator"
    extra_arguments  = [
      "-e", "ansible_winrm_server_cert_validation=ignore",
      "-e", "ansible_winrm_operation_timeout_sec=3600",
      "-e", "ansible_winrm_read_timeout_sec=3600"
    ]
  }

  # 2. Run Sysprep via PowerShell
  provisioner "powershell" {
    script = "./provisioners/scripts/run_sysprep.ps1"
  }

  # 3. Create Manifest Artifact
  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}