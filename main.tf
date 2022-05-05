terraform {
  required_providers {
    alicloud = {
      source = "aliyun/alicloud"
      version = "1.165.0"
    }
  }
}

# Configure the Alicloud Provider
provider "alicloud" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "alicloud_instance_types" "c1g1" {
  cpu_core_count = 1
  memory_size    = 1
}

data "alicloud_images" "default" {
  name_regex  = "^ubuntu"
  most_recent = true
  owners      = "system"
}

# Create a web server
resource "alicloud_instance" "web" {
  image_id             = "${data.alicloud_images.default.images.0.id}"
  internet_charge_type = "PayByBandwidth"

  instance_type        = "${data.alicloud_instance_types.c1g1.instance_types.0.id}"
  system_disk_category = "cloud_efficiency"
  security_groups      = ["${alicloud_security_group.default.id}"]
  instance_name        = "web1"
  vswitch_id           = "vsw-8vbrmlwa2ouiq370jfgfv"
}

# Create security group
resource "alicloud_security_group" "default" {
  name        = "default"
  description = "default"
  vpc_id      = "vpc-8vberb7dmsdjrfg9j2zwq"
}
