packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
  }
}

variable "output_dir" {
  type    = string
  default = "output"
}

variable "output_name" {
  type    = string
  default = "qemu-debian-bookworm.qcow2"
}

variable "source_checksum_url" {
  type    = string
  default = "file:https://cdimage.debian.org/cdimage/release/12.1.0/amd64/iso-cd/SHA256SUMS"
}

variable "source_iso" {
  type    = string
  default = "https://cdimage.debian.org/cdimage/release/12.1.0/amd64/iso-cd/debian-12.1.0-amd64-netinst.iso"
}

variable "root_password" {
  type    = string
  default = "root"
}

variable "http_proxy" {
  default = env("http_proxy")
}

variable "https_proxy" {
  default = env("https_proxy")
}

build {
  sources = ["source.qemu.debian"]

  provisioner "shell" {
    script = "configure-qemu-image.sh"
  }

  post-processor "shell-local" {
    keep_input_artifact = true
    inline = [
      "cd ${var.output_dir}/",
      "sha256sum ${var.output_name} > SHA256SUMS",
    ]
  }
}

source qemu "debian" {
  iso_url      = "${var.source_iso}"
  iso_checksum = "${var.source_checksum_url}"

  cpus = 1
  # The Debian installer warns with a dialog box if there's not enough memory
  # in the system.
  memory      = 1000
  disk_size   = 8000
  accelerator = "kvm"

  headless = true
  # vnc_bind_address = "0.0.0.0"

  # Serve preseed config for the Debian installer over HTTP.
  http_content = {
    "/preseed.cfg" = templatefile("preseed.cfg.pkrtpl", {
      http_proxy = var.http_proxy,
      https_proxy = var.https_proxy,
    }),
  }

  # SSH ports to redirect to the VM being built
  host_port_min = 2222
  host_port_max = 2229

  # This user is configured in the preseed file.
  ssh_username     = "root"
  ssh_password     = "${var.root_password}"
  ssh_wait_timeout = "1000s"

  shutdown_command = "/sbin/shutdown -hP now"

  # Builds a compact image
  disk_compression   = true
  disk_discard       = "unmap"
  skip_compaction    = false
  disk_detect_zeroes = "unmap"

  format           = "qcow2"
  output_directory = "${var.output_dir}"
  vm_name          = "${var.output_name}"

  boot_wait = "1s"
  boot_command = [
    "<down><tab>", # non-graphical install
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "language=en locale=en_US.UTF-8 ",
    "country=CH keymap=fr ",
    "hostname=packer domain=local ", # Should be overriden after DHCP, if available
    "<enter><wait>",
  ]
}
