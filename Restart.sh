#!/bin/bash
# Restart wiping / imaging services
echo "Restart Networking services"
echo " Q to continue"
echo "Restarting DHCP"
sudo service isc-dhcp-server restart
sudo service isc-dhcp-server status
echo ""
echo ""
echo ""
echo ""
echo ""
echo "Restarting tftp"
sudo service tftpd-hpa restart
sudo service tftpd-hpa status
echo ""
echo ""
echo ""
echo ""
echo ""
echo "Restarting nginx"
sudo service nginx restart
sudo service nginx status
echo ""
echo ""
echo ""
echo ""
echo ""
echo "Restarting Samba"
sudo service smbd restart
sudo service smbd status
sudo service nmbd restart
sudo service nmbd status
echo ""
echo ""
echo ""
echo ""
echo ""
echo "Restarting django"
sudo service django restart
sudo service django status
exit



echo ""
echo ""
echo ""
echo ""
echo ""
echo "Restarting avahi"
sudo service avahi-daemon restart
sudo service avahi-daemon status
echo ""
echo ""
echo ""
echo ""
echo ""
echo "Restarting nfs-kernel-server"
sudo service nfs-kernel-server restart
sudo service nfs-kernel-server status


