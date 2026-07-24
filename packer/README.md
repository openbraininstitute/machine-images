# Packer — Neurodamus Machine Images

Builds machine images for [Neurodamus](https://github.com/openbraininstitute/neurodamus) with all dependencies (NEURON, libsonata, HDF5, MPI, etc.) pre-compiled.

## Targets

| Source | Base OS | Use case |
|--------|---------|----------|
| `docker` | Amazon Linux 2023 | Local testing |
| `amazon-ebs` | AL2023 AMI | AWS PCS (EFA + Slurm) |
| `azure-arm` | Ubuntu HPC 24.04 | Azure HPC VMs |

## Usage

```bash
packer init .
packer build -only='docker.neurodamus' .       # local docker image
packer build -only='amazon-ebs.neurodamus' .   # AWS AMI
packer build -only='azure-arm.neurodamus' .    # Azure image
```

## Configuration

Pinned versions are in `variables.auto.pkrvars.hcl`. Variable definitions are in `variables.pkr.hcl`.
