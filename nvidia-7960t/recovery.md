NVIDIA RECOVERY PROCEDURE
=========================

Goal:
Restore working NVIDIA 595 open-driver stack on Ubuntu 22.04 with kernel 6.8.0-117-generic using the NVIDIA CUDA repository.

Symptoms this procedure fixes:
- nvidia-smi fails with "couldn't communicate with the NVIDIA driver"
- modprobe nvidia says module not found
- dkms status is empty
- system has mixed Ubuntu + NVIDIA CUDA repo packages

Pre-checks:
1. Verify Secure Boot is disabled:
   mokutil --sb-state

2. Verify GPUs are visible on PCIe:
   lspci | grep -i nvidia

3. Verify kernel:
   uname -r

Expected kernel:
- 6.8.0-117-generic

Install kernel headers:
sudo apt update
sudo apt install linux-headers-$(uname -r)

Install working NVIDIA packages from NVIDIA CUDA repo:
sudo apt install \
  nvidia-dkms-open \
  nvidia-firmware \
  nvidia-kernel-common \
  libnvidia-compute \
  libnvidia-cfg1 \
  libnvidia-decode \
  libnvidia-gpucomp \
  nvidia-persistenced

If dpkg reports firmware overwrite conflicts:
sudo dpkg -i --force-overwrite /var/cache/apt/archives/nvidia-firmware_595.71.05-1ubuntu1_amd64.deb
sudo apt-get -f install

Rebuild/verify DKMS:
sudo dkms autoinstall
dkms status

Expected:
- nvidia/595.71.05, 6.8.0-117-generic, x86_64: installed

Create repo pin file so apt keeps preferring NVIDIA CUDA repo packages:
sudo tee /etc/apt/preferences.d/nvidia-cuda-pin <<'EOF'
Package: nvidia-dkms-open nvidia-firmware nvidia-kernel-common libnvidia-compute libnvidia-cfg1 libnvidia-decode libnvidia-gpucomp nvidia-persistenced
Pin: origin developer.download.nvidia.com
Pin-Priority: 1001
EOF

Reboot:
sudo reboot

Post-reboot validation:
dkms status
lsmod | grep nvidia
modinfo -F version nvidia
nvidia-smi

Expected post-reboot state:
- nvidia-smi works
- Driver Version: 595.71.05
- CUDA Version: 13.2
- 3 GPUs detected
- NVIDIA kernel modules loaded

Important warning:
Do NOT mix these Ubuntu multiverse packages into the active stack:
- nvidia-utils-595
- libnvidia-compute-595
- nvidia-kernel-common-595
- nvidia-firmware-595-595.71.05

Root cause of previous failures:
- Driver stack was split across two package sources:
  1. Ubuntu jammy-updates/jammy-security
  2. NVIDIA CUDA repository
- That caused dkms/open-driver packages to disappear or be replaced during apt operations.

Useful diagnostic commands:
dpkg -l | egrep 'nvidia|libnvidia'
apt-cache policy nvidia-dkms-open nvidia-firmware nvidia-kernel-common libnvidia-compute libnvidia-cfg1
find /lib/modules/$(uname -r) -type f | grep nvidia
journalctl -b -k | grep -iE 'nvidia|NVRM|dkms'
lspci | grep -i 'VGA compatible controller: NVIDIA'

Known separate issue:
- Only 3 GPUs are detected although 4 are physically installed.
- This is likely a PCIe/BIOS/hardware resource issue, not a driver installation issue.

## Missing 4th NVIDIA GPU

We found the reason that the 4th NVIDIA GPU sometimes did not show: the power cable from the mainbaord to the card was defective.

## Power issue

Sometimes, `nvidia-smi` shows the NVIDIA card correctly. However, `ollama` is still not able to use the cards. This is a power management issue. We solved it with this configuration:

### Apply the GRUB fix (Fixes the reboot hang/missing GPUs)

```
bash
Copy
sudo nano /etc/default/grub  
# Change the line to:  
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash pcie_aspm=off"  
sudo update-grub  
```

### Apply the Modprobe fix (Fixes mid-session GPU drops)

```
bash
Copy
sudo tee /etc/modprobe.d/nvidia-power.conf <<EOF  
options nvidia NVreg_DynamicPowerManagement=0x00  
EOF
```
