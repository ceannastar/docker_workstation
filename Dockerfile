FROM debian:latest

RUN apt-get update && apt-get install -y \
    kde-plasma-desktop \
    xrdp \
    dbus-x11 \
    locales \
    sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i '/^# *\(en_US.UTF-8\)/s/^# *//' /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN useradd -rm -d /home/workstation -s /bin/bash -g root -G sudo -u 1000 workstation && \
    echo 'workstation:password' | chpasswd && \
    echo 'workstation ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER workstation
WORKDIR /home/workstation

RUN echo '#!/bin/bash\n\
\n\
for i in {1..10}; do\n\
    if [ -n "$DISPLAY" ]; then\n\
        break\n\
    fi\n\
    sleep 1\n\
done\n\
\n\
export LANG=en_US.UTF-8\n\
export LANGUAGE=en_US:en\n\
export LC_ALL=en_US.UTF-8\n\
\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
unset XDG_RUNTIME_DIR\n\
\n\
exec startplasma-x11\n' > /home/workstation/.xsession && chmod +x /home/workstation/.xsession

RUN echo 'export LANG=en_US.UTF-8\n\
export LANGUAGE=en_US:en\n\
export LC_ALL=en_US.UTF-8' >> /home/workstation/.profile

USER root

RUN echo 'allowed_users=anybody' > /etc/X11/Xwrapper.config && \
    echo 'needs_root_rights=yes' >> /etc/X11/Xwrapper.config

RUN mkdir -p /var/run/xrdp && \
    chown root:root /var/run/xrdp && \
    chmod 755 /var/run/xrdp

RUN echo '#!/bin/bash\n\
\n\
rm -f /var/run/xrdp/*.pid 2>/dev/null\n\
\n\
if ! pgrep -x "dbus-daemon" > /dev/null; then\n\
    dbus-daemon --system --fork\n\
    sleep 2\n\
fi\n\
\n\
echo "#!/bin/sh\n\
export LANG=en_US.UTF-8\n\
export LANGUAGE=en_US:en\n\
export LC_ALL=en_US.UTF-8\n\
export XDG_SESSION_TYPE=X11\n\
startplasma-x11" > /etc/xrdp/startwm.sh\n\
chmod +x /etc/xrdp/startwm.sh\n\
\n\
/usr/sbin/xrdp-sesman --nodaemon 2>&1 &\n\
SESMAN_PID=$!\n\
echo "sesman started with PID: $SESMAN_PID"\n\
sleep 3\n\
\n\
/usr/sbin/xrdp --nodaemon 2>&1 &\n\
XRDP_PID=$!\n\
echo "xrdp started with PID: $XRDP_PID"\n\
\n\
wait $SESMAN_PID $XRDP_PID\n' > /start.sh && chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]