#!/bin/zsh

d=${0:a:h}
l=${0:a:h:h}
sh_f_docker=$l/dockerfile/docker-arch/bin/mkimage-arch-jp.sh
sh_d=$l/dockerfile/docker-arch/mkimage-arch
t=$sh_f_docker
cat $t|grep -n PACMAN_MIRRORLIST=

tmp=`zsh -c "ls -A $sh_d"|grep .sh`
n=`echo "$tmp"| wc -l`
for ((i=1;i<=$n;i++))
do
	t=$sh_d/`echo "$tmp"| awk "NR==$i"`
	cat $t|grep -n PACMAN_MIRRORLIST=
done

