#!/bin/bash
set -euxo pipefail

# Install required packages
apt-get update
apt-get install -y curl ca-certificates open-iscsi nfs-common

# Enable iSCSI service
systemctl enable iscsid
systemctl start iscsid

# Wait up to 10 minutes for Azure data disk at LUN 0
DISK="/dev/disk/azure/scsi1/lun0"

for i in $(seq 1 120); do
  if [ -b "$DISK" ]; then
    break
  fi
  sleep 5
done

if [ ! -b "$DISK" ]; then
  echo "Azure data disk at LUN 0 was not found."
  exit 1
fi

# Format the disk only if no filesystem exists
if ! blkid "$DISK"; then
  mkfs.ext4 -F "$DISK"
fi

# Mount the disk persistently
UUID=$(blkid -s UUID -o value "$DISK")

mkdir -p /mnt/observability

if ! grep -q "$UUID" /etc/fstab; then
  echo "UUID=$UUID /mnt/observability ext4 defaults,nofail 0 2" >> /etc/fstab
fi

mount /mnt/observability

# Prepare K3s data directory
mkdir -p /mnt/observability/k3s

# Install K3s on the mounted managed disk
curl -sfL https://get.k3s.io -o /tmp/install-k3s.sh

INSTALL_K3S_EXEC="server --data-dir /mnt/observability/k3s" \
  sh /tmp/install-k3s.sh

# Enable and start K3s
systemctl enable --now k3s

# Configure kubectl for the VM administrator
mkdir -p /home/vijayadmin/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vijayadmin/.kube/config

chown -R vijayadmin:vijayadmin /home/vijayadmin/.kube
chmod 600 /home/vijayadmin/.kube/config

echo "K3s installation completed successfully."
