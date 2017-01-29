FROM archlinuxjp/archlinux

RUN pacman -Syy arch-install-scripts expect docker --noconfirm
RUN mkdir -p /run/shm
ADD bin/mkimage-arch-jp.sh /
ADD bin/mkimage-arch-pacman.conf /

CMD /bin/bash
