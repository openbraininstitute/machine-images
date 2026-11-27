#!/usr/bin/env bash

# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/efa-changelog.html
EFA_VERSION=1.47.0

# The versions available for both the PCS_SLURM, and PCS_AGENT, and their SHA256 checksums are here:
# https://docs.aws.amazon.com/pcs/latest/userguide/working-with_ami_installers.html

# Slurm installers to put in the image, as "<installer version> <sha256>".
#
# Several major versions can be installed side by side (each goes to
# /opt/aws/pcs/scheduler/slurm-<major>); at boot, the PCS agent starts the newest
# installed slurmd that is compatible with the cluster controller's version.
# Keeping the cluster's current version next to the target one lets the same
# AMI work before and after the controller is updated (rolling update):
# https://docs.aws.amazon.com/pcs/latest/userguide/working-with_clusters_version_update.html
#
# Supported versions / EOL dates:
# https://docs.aws.amazon.com/pcs/latest/userguide/slurm-versions.html
# Release notes:
# https://docs.aws.amazon.com/pcs/latest/userguide/slurm-versions_release-notes.html
PCS_SLURM_INSTALLERS=(
   # 25.05 is EOL on 2026-11-30; drop it once all clusters run 26.05
   "25.05.9-2 43840f51773c8ffc2ee055f1a035d281532c3fe48ba37eb6e227f62c1d5091c2"
   "26.05.5-2 d079c49c9edd1ae02e668b754cc8fa13953924d23a36355617bf137662a3a51a"
)

# https://docs.aws.amazon.com/pcs/latest/userguide/pcs-agent-versions.html
# rolling Slurm version updates require >= v1.5.1-1
PCS_AGENT_VERSION=v1.6.0-1
PCS_AGENT_SHA256=8e0d66b595a11cd738190ffe29941269b2c5fbb29d5ba58f0ac3e70062b538ae

REGION=us-east-1
PCS_REPO=https://aws-pcs-repo-$REGION.s3.$REGION.amazonaws.com

# download $1 to $2 and check its sha256 against $3
fetch-verified () {
   curl -fsSL -o "$2" "$1"
   echo "$3  $2" | sha256sum --check --strict
}

install-efa () {
   echo "========== Install aws-efa =========="
   cd /tmp
   curl -o efa-installer.tar.gz https://efa-installer.amazonaws.com/aws-efa-installer-$EFA_VERSION.tar.gz
   tar xf efa-installer.tar.gz && cd aws-efa-installer
   ./efa_installer.sh -y --mpi=openmpi5
}

install-pcs-slurm () {
   local entry version sha256 major
   for entry in "${PCS_SLURM_INSTALLERS[@]}"; do
      read -r version sha256 <<< "$entry"
      major=${version%.*-*}  # 26.05.5-2 -> 26.05

      echo "========== Install aws-pcs-slurm $version =========="
      cd /tmp
      fetch-verified "$PCS_REPO/aws-pcs-slurm/aws-pcs-slurm-$major-installer-$version.tar.gz" \
         "aws-pcs-slurm-$major.tar.gz" "$sha256"
      tar xf "aws-pcs-slurm-$major.tar.gz" && cd "aws-pcs-slurm-$major-installer/"
      ./installer.sh -y

      test -x "/opt/aws/pcs/scheduler/slurm-$major/sbin/slurmd"
      test -f "/etc/systemd/system/slurmd-$major.service"
   done
}

install-pcs-agent () {
   echo "========== Install aws-pcs-agent =========="
   cd /tmp
   fetch-verified "$PCS_REPO/aws-pcs-agent/aws-pcs-agent-$PCS_AGENT_VERSION.tar.gz" \
      aws-pcs-agent.tar.gz "$PCS_AGENT_SHA256"
   tar xf aws-pcs-agent.tar.gz && cd aws-pcs-agent
   ./installer.sh
}

install-aws-deps () {
   yum install -y python3.11

   install-efa
   install-pcs-slurm
   install-pcs-agent
}
