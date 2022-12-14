provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_instance" "example" {
    ami           =  "ami-0af2f764c580cc1f9" 
    instance_type = "t2.micro"
    root_device_name  = "/dev/xvda"
    key_name = ""
    ebs_block_device {
      device_name = "/dev/xvda"
      snapshot_id = "snap-xxxxxxxx"
      volume_size = 30
    }
}