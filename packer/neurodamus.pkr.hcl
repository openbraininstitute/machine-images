source "docker" "neurodamus" {
  image  = "amazonlinux:2023"
  commit = true
  changes = [
    "ENV INSTALL_DIR=/opt/obi",
  ]
  volumes = {
    "./cache" = "/cache",
    "./cache/yum" = "/var/cache/dnf/",
  }
}

source "amazon-ebs" "neurodamus" {
  ami_name      = "neurodamus-${var.neurodamus_commit}-{{timestamp}}"
  instance_type = var.aws_instance_type
  region        = var.aws_region
  source_ami_filter {
    filters = {
      name                = "al2023-ami-2023.*-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["amazon"]
    most_recent = true
  }
  ssh_username = "ec2-user"
}

source "azure-arm" "neurodamus" {
    use_azure_cli_auth = true

    # see: https://github.com/Azure/azhpc-images
    # and: https://learn.microsoft.com/en-us/azure/virtual-machines/azure-hpc-vm-images
    os_type         = "Linux"
    image_publisher = "microsoft-dsvm"
    image_offer     = "ubuntu-hpc"
    image_sku       = "2404"

    #location = "southcentralus"
    location = var.az_region
    vm_size  = var.az_instance_type

    managed_image_name                = "neurodamus-${var.neurodamus_commit}-{{timestamp}}"
    managed_image_resource_group_name = var.az_resource_group
}

build {
  sources = [
    "source.docker.neurodamus",
    "source.amazon-ebs.neurodamus",
    "source.azure-arm.neurodamus",
  ]

  provisioner "shell" {
    # amazon-ebs requires sudo; to keep everything else the same between the builders
    # install sudo in docker, eventhough we are already root
    only            = ["docker.neurodamus"]
    inline          = ["dnf install -y -v --setopt=keepcache=1 sudo"]
  }

  provisioner "shell" {
    only            = ["amazon-ebs.neurodamus"]
    inline          = [
      "sudo mkdir /cache",
      "sudo chown -R ec2-user /cache",
    ]
  }

  provisioner "shell" {
    only            = ["docker.neurodamus", "amazon-ebs.neurodamus"]
    inline = [
      #"sudo dnf -y update",
      "sudo dnf install -y tar gzip",
    ]
  }

  provisioner "shell" {
    execute_command  = "sudo /usr/bin/env bash {{ .Path }}"
    inline = [
      <<-EOF
      cat <<'SCRIPT' | tee /etc/profile.d/uv-env-vars.sh
      export UV_PYTHON=python${var.python_version}
      export UV_LINK_MODE=copy
      export UV_PYTHON_CACHE_DIR=/cache/uv
      export UV_PYTHON_INSTALL_DIR=/uv/python
      export UV_CACHE_DIR=/cache/uv
      export UV_COMPILE_BYTECODE=1
      export UV_INSTALL_DIR=/uv
      export PATH=/uv/:$PATH
      SCRIPT
      source /etc/profile
      curl -fsSL https://astral.sh/uv/${var.uv_version}/install.sh | sh
      uv python install ${var.python_version}
      EOF
    ]
  }

  provisioner "shell-local" {
    inline = [
      "[ -e neurodamus ] || git clone --no-checkout --filter=blob:none https://github.com/openbraininstitute/neurodamus/ neurodamus",
      "cd neurodamus && git fetch --tags && git sparse-checkout set --no-cone 'ci/scripts/*' && git checkout ${var.neurodamus_script_commit}",
    ]
  }

  provisioner "file" {
    source      = "neurodamus/ci/scripts"
    destination = "/tmp/"
    generated   = true
  }

  provisioner "file" {
    only        = ["docker.neurodamus", "amazon-ebs.neurodamus"]
    source      = "install-aws-deps.sh"
    destination = "/tmp/scripts/"
  }

  provisioner "shell" {
    execute_command  = "sudo {{ .Vars }} /usr/bin/env bash -l {{ .Path }}"
    environment_vars = [
      "INSTALL_DIR=/opt/obi",
      "BUILD_DIR=/cache/build",
      "CMAKE_BUILD_TYPE=RelWithDebugInfo",
      "BUILD_TARGET=${source.type}",

      "SCCACHE_DIR=/cache/sccache",
    ]
    inline = [
      "set -euo pipefail",
      "is-amazon() { [[ $BUILD_TARGET = 'amazon-ebs' ]] }",
      "is-azure()  { [[ $BUILD_TARGET = 'azure-arm' ]] }",
      "is-docker() { [[ $BUILD_TARGET = 'docker' ]] }",
      "unchecked-source() { set +u; source \"$1\"; set -u; }",

      "export PATH=$HOME/.local/bin:$PATH",
      "export SUDO=''",
      "export DNF_OPTIONS=''",

      "is-docker && export DNF_OPTIONS='-v --setopt=keepcache=1'",

      "(is-docker || is-amazon ) && source /tmp/scripts/install-dnf-dependencies.sh && install-dnf-dependencies",
      "is-azure && source /tmp/scripts/install-apt-dependencies.sh && install-apt-dependencies",
      "is-azure && source /usr/share/modules/init/bash && module load mpi/openmpi",

      "is-docker && dnf install -y $DNF_OPTIONS openmpi-devel && unchecked-source /etc/profile && module load mpi/openmpi-x86_64",
      "is-amazon && source /tmp/scripts/install-aws-deps.sh && install-aws-deps && unchecked-source /etc/profile && module load openmpi5 libfabric-aws",

      "module list",

      "uv venv $INSTALL_DIR/venv",
      "unchecked-source $INSTALL_DIR/venv/bin/activate",

      "echo $-",

      "source /tmp/scripts/install-python-dependencies.sh && PIP='uv pip' install-python-dependencies",

      "source /tmp/scripts/install-sccache.sh && install-sccache",

      "source /tmp/scripts/install-hdf5.sh && install-hdf5",

      "source /tmp/scripts/install-h5py.sh && PIP='uv pip' install-h5py",

      "source /tmp/scripts/build-libsonatareport.sh && build-libsonatareport ${var.libsonatareport_commit}",

      "source /tmp/scripts/build-libsonata.sh && PIP='uv pip' build-libsonata ${var.libsonata_commit}",

      "source /tmp/scripts/build-neuron.sh && PIP='uv pip' build-neuron ${var.neuron_commit}",

      "source /tmp/scripts/build-neurodamus.sh && PIP='uv pip' build-neurodamus ${var.neurodamus_commit}",

      "source /tmp/scripts/make-neurodamus-nrnivmodl.sh && make-neurodamus-nrnivmodl",

      "export PATH=/opt/obi:$PATH && source /tmp/scripts/make-neocortex-env.sh && BASE_DIR=$BUILD_DIR/neurodamus make-neocortex-env",

      "is-amazon && dnf clean all",

      "uv -vv cache prune --ci",

      "true",
    ]
  }
}
