NVIDIA WORKING INVENTORY
========================

Host OS:
- Ubuntu 22.04 LTS

Kernel:
- 6.8.0-117-generic

GPU state:
- nvidia-smi works after reboot
- Detected GPUs: 3
- Driver Version: 595.71.05
- CUDA Version reported by nvidia-smi: 13.2
- Driver type: NVIDIA Open Kernel Module

Active NVIDIA package source:
- NVIDIA CUDA repository:
  https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64

Installed working NVIDIA packages from NVIDIA CUDA repo:
- nvidia-dkms-open           595.71.05-1ubuntu1
- nvidia-firmware            595.71.05-1ubuntu1
- nvidia-kernel-common       595.71.05-1ubuntu1
- libnvidia-compute          595.71.05-1ubuntu1
- libnvidia-cfg1             595.71.05-1ubuntu1
- libnvidia-decode           595.71.05-1ubuntu1
- libnvidia-gpucomp          595.71.05-1ubuntu1
- nvidia-persistenced        595.71.05-1ubuntu1

Related NVIDIA/container packages present:
- libnvidia-container-tools  1.19.0-1
- libnvidia-container1       1.19.0-1
- nvidia-container-toolkit   1.19.0-1
- nvidia-container-toolkit-base 1.19.0-1
- nvidia-modprobe            595.71.05-1ubuntu1
- nvidia-settings            595.71.05-1ubuntu1

DKMS status:
- nvidia/595.71.05, 6.8.0-117-generic, x86_64: installed

Kernel modules installed under:
- /lib/modules/6.8.0-117-generic/updates/dkms/

Expected NVIDIA module files:
- nvidia.ko
- nvidia-modeset.ko
- nvidia-drm.ko
- nvidia-uvm.ko
- nvidia-peermem.ko

Secure Boot:
- disabled

Important note:
- The working configuration uses NVIDIA CUDA repo packages for the active driver stack.
- Mixing Ubuntu multiverse NVIDIA packages with NVIDIA CUDA repo packages caused breakage.

Conflicting Ubuntu packages seen earlier and should NOT be mixed into the active stack:
- nvidia-utils-595                 595.71.05-0ubuntu0.22.04.1
- libnvidia-compute-595           595.71.05-0ubuntu0.22.04.1
- nvidia-kernel-common-595        595.71.05-0ubuntu0.22.04.1
- nvidia-firmware-595-595.71.05   595.71.05-0ubuntu0.22.04.1

Pinning file used to prefer NVIDIA CUDA repo packages:
- /etc/apt/preferences.d/nvidia-cuda-pin

Pin file contents:
Package: nvidia-dkms-open nvidia-firmware nvidia-kernel-common libnvidia-compute libnvidia-cfg1 libnvidia-decode libnvidia-gpucomp nvidia-persistenced
Pin: origin developer.download.nvidia.com
Pin-Priority: 1001

Validation commands:
- dkms status
- lsmod | grep nvidia
- modinfo -F version nvidia
- nvidia-smi
- lspci -nn | grep -i nvidia
