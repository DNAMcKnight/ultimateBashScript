#!/usr/bin/bash


screenSetup () {
    echo "Installing screen..."
    sudo apt-get install screen
    echo "Screen installation complete!"
}


microSetup () {
    echo "Downloading micro..."
    curl https://getmic.ro | bash
    echo "Changing permissions for micro"
    sudo chown root:root micro
    echo "Micro installation complete!"
    sudo mv micro /usr/local/bin
    echo "Moving micro to /usr/local/bin"
    which micro
}


smbConfWrite () {
    echo "
[usb]
    comment = Media Share
    path = /media/USBDrive
    writeable = yes
    force group = pi
    create mask = 0660
    directory mask = 0771
    read only = no

[pi-share]
    comment = Pi Share
    path = /home/pi
    writeable = yes
    force group = pi
    create mask = 0660
    directory mask = 0771
    read only = no" >> /etc/samba/smb.conf
    echo "done!"
    echo "resetting smbd"
    sudo systemctl restart smbd
    sleep 5
    echo "done"
}


sambaSetup () {
    echo "Setting up samba"
    cd /media
    sudo mkdir USBDrive
    sudo umount /dev/sda1
    echo "mounting /dev/sda1 /media/USBDrive"
    sudo mount /dev/sda1 /media/USBDrive
    echo "Downloading samba..."
    sudo apt-get install samba samba-common-bin
    echo "creating backup for smb.conf"
    cp /etc/samba/smb.conf /etc/samba/smb.conf.bak  #Make a backup of the config file
    echo "Please enter samba password"
    read pass
    sudo smbpasswd -a $pass
    echo "Please run setup.sh {sambaConfig} to update the config"
}

case "$1" in
    screen)
        screenSetup
        exit 1
        ;;
    micro)
        microSetup
        exit 1
        ;;
    samba)
        sambaSetup
        exit 1
        ;;
    
    sambaConfig)
        smbConfWrite
        exit 1
        ;;
    
    all)
        screenSetup
        microSetup
        exit 1
        ;;
    *)
        echo "Usage: setup.sh {screen|micro|samba|all}"
        exit 1
        ;;
esac

exit 0