#!/bin/bash
set -e
cd $(dirname $0)
[ $(whoami) == root ] || exit 1

echo "Installing packages"
pkgs=$(sed -r 's/#.*$//g' apt.txt)
dpkg -l $pkgs || (apt-get update; apt-get install $pkgs)

echo "Create users"
passwd --status test || useradd --create-home --shell /bin/bash test
passwd --delete --lock test
passwd --status x || (useradd --create-home --shell /bin/bash x; passwd x)

echo "Security hardening"
chmod 700 /root
[ -f /tmp/rcconf.hardened ] || (rcconf; touch /tmp/rcconf.hardened)

echo "Move .bashrc"
mv /etc/skel/.bashrc /etc/skel/.bashrc-$(date +%s)
cp ./etc/skel/.bashrc /etc/skel/.bashrc
ln -sf /etc/skel/.bashrc /root/.bashrc
ln -sf /etc/skel/.bashrc /home/x/.bashrc
ln -sf /etc/skel/.bashrc /home/test/.bashrc

echo "Deploy configs"
cp -r ./home/x/.config /home/x/
chown -R x:x /home/x/.config

echo "Setup gnome"
apt remove gnome-shell-extension-dashtodock
cd /home/x
su x -c bash << END
rm -rf Видео/ Документы/ Загрузки/ Изображения/ Музыка/ Общедоступные/ Рабочий\ стол/ Шаблоны/
mkdir -p vid doc down img desk
xdg-user-dirs-update
[ -f img/default.jpg ] || wget "https://drive.google.com/uc?id=1rmFsfFNBaDNVigfYwCT__4B757jRbrND&export=download" -O img/default.jpg
dconf load /org/ < .config/org.dconf
rm -f .config/org.dconf
END
cd -

echo
echo "*********************"
echo "*     WARNING       *"
echo "*********************"
echo
echo "Reboot system to update gnome settings"
echo
