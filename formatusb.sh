#!/bin/bash

# Author: misterfonka
# Purpose: Format a removable USB drive in the linux terminal.

# List attached USB drives
echo "Attached USB drives:"
lsblk -do NAME,SIZE,MODEL | grep -e '^sd'

# Prompt for drive selection
read -p "Select a USB drive (enter the corresponding drive label, e.g sda): " drive_label

# Verify the selected drive
if [[ -z $drive_label ]]; then
  echo "Invalid drive selection."
  exit 1
fi
clear
drive_name="/dev/$drive_label"
echo    "You have selected to erase: $drive_name"
echo    ""
echo    "Are you sure you want to continue? This will erase"
echo    "the drive with all zeros meaning it will take a VERY"
echo    "long time depending on how big the drive is."
echo    ""
read -p "Enter DoIt to proceed: " doit

if [[ "$doit" = "DoIt" ]];then
  clear
  echo "Let's do it."
else
  clear
  echo "User didn't want to DoIt... :("
  exit 0
fi

# Unmount the drive if it is currently mounted
clear
echo "Unmounting drive..."
umount "$drive_name"*

# Erase the drive with zeros
clear
echo "Erasing drive... this may take a while."
dd if=/dev/zero of="$drive_name" bs=4M status=progress

# Create a new partition
clear
echo "Creating new partition..."
parted "$drive_name" mklabel msdos
parted -a opt "$drive_name" mkpart primary fat32 0% 100%

# Format the partition with FAT32
clear
echo "Formatting partition with FAT32..."
mkfs.fat -F 32 "${drive_name}1"

# Tell the user that there USB drive has been formatted.
clear
echo "USB drive $drive_name has been erased and formatted with FAT32."
