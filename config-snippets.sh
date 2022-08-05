# the file is not for run
exit

# disable wake on mouse
echo disabled > /sys/bus/usb/devices/1-1/power/wakeup

# nvidia on-demand
export __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia

# default file manager
xdg-mime default xfe.desktop inode/directory application/x-gnome-saved-search
