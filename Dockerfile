FROM kalilinux/kali-rolling:arm64

MAINTAINER xansx

ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update && apt-get install -y kali-linux-default

RUN apt-get update && \
    apt-get install -y --no-install-recommends evince file-roller gnome-themes-standard gpicview gtk2-engines-pixbuf ttf-ubuntu-font-family xfce4 xfce4-whiskermenu-plugin xorg xserver-xorg xfce4-indicator-plugin xfce4-terminal numix-icon-theme numix-icon-theme-circle

RUN apt-get install -y xrdp locales supervisor sudo ibus ibus-mozc dbus dbus-x11 curl inetutils-ping firefox-esr rlwrap


RUN apt --fix-broken install
RUN locale-gen es_ES && \
    apt-get install -y git tigervnc-standalone-server && \
    git clone https://github.com/novnc/noVNC.git /root/noVNC && \
    git clone https://github.com/novnc/websockify.git /root/noVNC/utils/websockify

RUN mkdir -p /var/run/dbus

RUN sed -i -e 's/LogLevel=DEBUG/LogLevel=CORE/g' /etc/xrdp/xrdp.ini && \
    sed -i -e 's/SyslogLevel=DEBUG/SyslogLevel=CORE/g' /etc/xrdp/xrdp.ini && \
    sed -i -e 's/EnableSyslog=true/EnableSyslog=false/g' /etc/xrdp/xrdp.ini && \
    sed -i -e 's/LogLevel=DEBUG/LogLevel=CORE/g' /etc/xrdp/sesman.ini && \
    sed -i -e 's/SyslogLevel=DEBUG/SyslogLevel=CORE/g' /etc/xrdp/sesman.ini && \
    sed -i -e 's/EnableSyslog=true/EnableSyslog=false/g' /etc/xrdp/sesman.ini

RUN useradd -m -s /bin/bash -G sudo xuser

COPY Adwaita-dark-Xfce-with-Qbox-mw4 /usr/share/themes/Adwaita-dark-Xfce-with-Qbox-mw4
COPY xfce-perchannel-xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml
COPY xfce-perchannel-xml /home/xuser/.config/xfce4/xfconf/xfce-perchannel-xml
COPY helpers.rc /etc/xdg/xfce4/helpers.rc

RUN ln -s /root/noVNC/vnc.html /root/noVNC/index.html && \
    ln -s /usr/share/icons/Numix-Circle /usr/share/icons/KXicons && \
    chown -R xuser /usr/share/themes/Adwaita-dark-Xfce-with-Qbox-mw4 && \
    chown -R xuser /usr/share/icons/KXicons && \
    chown -R xuser /etc/xdg/xfce4/xfconf/xfce-perchannel-xml


#RUN ln -s /root/noVNC/vnc_lite.html /root/noVNC/index.html && \
#    ln -s /usr/share/icons/Numix-Circle /usr/share/icons/KXicons && \
#    chown -R xuser /usr/share/themes/Adwaita-dark-Xfce-with-Qbox-mw4 && \
#    chown -R xuser /usr/share/icons/KXicons && \
#    chown -R xuser /etc/xdg/xfce4/xfconf/xfce-perchannel-xml

RUN echo "xfce4-session" > /etc/skel/.xsession
    
RUN apt-get install -y xfce4-taskmanager mousepad wget

RUN wget https://oswallpapers.com/wp-content/uploads/2020/04/default-1.jpg -O /usr/share/backgrounds/xfce/default.jpg

RUN apt full-upgrade -y

RUN apt-get install -y exploitdb locate
RUN updatedb

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


COPY install_tmux/* install_tmux/
COPY install_vim/* install_vim/
RUN chmod +x install_tmux/install.sh && /install_tmux/install.sh && chmod +x install_vim/install.sh && install_vim/install.sh
COPY bashrc /home/skel/.bashrc
COPY bashrc /home/xuser/.bashrc
COPY bashrc /root/.bashrc
COPY xrandr_config /home/xuser/xrandr_config

RUN apt-get update && apt-get install -y openvpn

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf


ENTRYPOINT ["./entrypoint.sh"]
