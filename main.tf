####setup a ec2 instance with public ip and another 21G disk
####and a db instance
####


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
  vswitch_id           = "${var.switchid}"
  internet_max_bandwidth_out = 4

  data_disks {
    name        = "disk2"
    size        = 21
    category    = "cloud_efficiency"
    description = "disk2"
  }
}

# Create security group
resource "alicloud_security_group" "default" {
  name        = "default"
  description = "default"
  vpc_id      = "${var.vpcid}"
}

# create db
resource "alicloud_db_instance" "mydb1" {
  engine               = "MySQL"
  engine_version       = "5.7"
  instance_type        = "mysql.n1.micro.1"
  instance_storage     = "30"
  instance_charge_type = "Postpaid"
  instance_name        = var.db1name
  vswitch_id           = "${var.switchiddb}"
  monitoring_period    = "60"
  parameters {
    name  = "innodb_large_prefix"
    value = "ON"
  }
}

