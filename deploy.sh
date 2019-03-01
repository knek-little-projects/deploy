#!/bin/bash
set -xe
cd $(dirname $0)
echo "Checking rights (must be root in a protected readable directory)"
[[ $(whoami) == "root" && $(stat --format %U:%G:%A .) == "root:root:drwxr-xr-x" ]] || exit 1


echo "Installing packages"
pkgs=$(sed -r 's/#.*$//g' apt.txt)
dpkg -l $pkgs || (apt-get update; apt-get install $pkgs)


echo "Create users"
passwd --status test || useradd --create-home --shell /bin/bash test
passwd --delete --lock test
passwd --status x || (useradd --create-home --shell /bin/bash x; passwd x)


echo "Security hardening"
chmod 700 /root /home/x /home/test
[ -f /tmp/rcconf.hardened ] || (rcconf; touch /tmp/rcconf.hardened)


echo "Rewrite .bashrc"

inodecompare() {
  [ -f "$1" ]
  [ -f "$2" ]
  [[ $(stat --format %i "$1") == $(stat --format %i "$2") ]]
}

if ! inodecompare /etc/skel/.bashrc ./etc/skel/.bashrc
then
    rm -f /etc/skel/.bashrc
    ln -f ./etc/skel/.bashrc /etc/skel/.bashrc
fi
ln -sf /etc/skel/.bashrc /root/.bashrc
ln -sf /etc/skel/.bashrc /home/x/.bashrc
ln -sf /etc/skel/.bashrc /home/test/.bashrc

echo "Fill /etc/"
inodecompare /etc/nanorc ./etc/nanorc || ln -f ./etc/nanorc /etc/nanorc

echo "Deploy /usr"
ln -sf $PWD/usr/bin/alert /usr/bin/
ln -sf $PWD/usr/share/nano/nmap.nanorc /usr/share/nano/

echo "Deploy configs"
cp -rf ./home/x/.config /home/x/
chown -R x:x /home/x/.config

cd ./home/x/.config/openbox
for f in $(ls -1); do
    ln -f $PWD/$f /home/x/.config/openbox
done
cd -

echo "Setup gnome"
apt remove gnome-shell-extension-dashtodock

rm -rf /root/Desktop

cd /home/x
su x -c bash << END
rm -rf Видео/ Документы/ Загрузки/ Изображения/ Музыка/ Общедоступные/ Рабочий\ стол/ Шаблоны/
mkdir -p vid doc down img desk
xdg-user-dirs-update
[[ -f img/default.jpg ]] || wget "https://drive.google.com/uc?id=1rmFsfFNBaDNVigfYwCT__4B757jRbrND&export=download" -O img/default.jpg
dconf load /org/ < .config/org.dconf
rm -f .config/org.dconf
END
cd -


echo "Install docker"
./docker-install.sh


echo "Reboot system to update gnome settings"
