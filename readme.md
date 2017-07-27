[![Build Status](https://travis-ci.org/ArchLinuxJP/docker-archlinux.svg?branch=master)](https://travis-ci.org/ArchLinuxJP/docker-arch)

Arch LinuxのDockerイメージをDocker Hubにて配布しています。

https://hub.docker.com/r/archlinuxjp

これらのDockerイメージは[GitHubリポジトリ](https://github.com/archlinuxjp/docker-arch)からTravis CIでPushされ、`Cron Jobs`の機能によって日々更新されています。

使用するスクリプトは[docker/docker](https://github.com/docker/docker/blob/master/contrib/mkimage-arch.sh)のスクリプトを参考に作成されています。スクリプトは`mkimage-arch/`以下にあります。

## 使用例

```bash
$ sudo docker pull archlinuxjp/archlinux
$ sudo docker run -it archlinuxjp/archlinux /bin/bash
```

## ビルド例

```bash
$ git clone https://github.com/archlinuxjp/docker-arch.git
$ sudo docker build -t tmp ./docker-arch/dockerfile/archlinux
$ sudo docker run -it tmp /bin/bash
```

## Arch LinuxのDockerイメージ作成例

```
$ sudo docker pull archlinuxjp/docker-arch
$ sudo docker run -v /var/run/docker.sock:/var/run/docker.sock --privileged -d -it archlinuxjp/docker-arch /bin/bash
$ export id=`sudo docker ps -q | peco`
$ sudo docker exec $id docker-arch base
$ sudo docker exec $id /bin/bash /mkimage-arch-jp.sh
```

## 履歴

2017.01.29 複数あったGitHubリポジトリを`archlinuxjp/docker-arch`に集約しました。

2017.07.27 yaourtのbuild処理が失敗するので一旦無効にしました。

> .travis.yml

```
docker run -v /var/run/docker.sock:/var/run/docker.sock --privileged -it yaourt /bin/bash /mkimage-arch-jp.sh;
docker push $DOCKER_TEARM/archlinux-yaourt;
```

2017.07.27 docker hubでsource linkがgithubにリンクされており、そのリンクが無効であったため、一旦、当該docker hubのrepositoryを削除後に再度repositoryを作成することにより無効リンクの表示を直しました。

注意点として、この作業は仕組み自体がdockerイメージの再利用であることから、docker repoを削除後、手動でdocker pushしなければなりませんでした。よって、repositoryを削除する前にdockr pullしておく必要がありました。

