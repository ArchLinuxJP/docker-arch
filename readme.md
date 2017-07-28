# docker-arch

[![Build Status](https://travis-ci.org/ArchLinuxJP/docker-archlinux.svg?branch=master)](https://travis-ci.org/ArchLinuxJP/docker-arch)

source : https://github.com/ArchLinuxJP/docker-arch

download : https://hub.docker.com/r/archlinuxjp

Arch LinuxのDockerイメージを[Docker Hub](https://hub.docker.com/r/archlinuxjp)にて配布しています。常に最新のイメージを使用することができます。

これらのDockerイメージは[GitHubリポジトリ](https://github.com/archlinuxjp/docker-arch)からTravis CIでPushされ、`Cron Jobs`の機能によって日々更新されています。

使用するスクリプトは[docker/docker](https://github.com/docker/docker/blob/master/contrib/mkimage-arch.sh)のスクリプトを参考に作成されています。スクリプトは`/dockerfile/docker-arch/mkimage-arch/`以下にあります。

詳しくはこちらを確認してください。

https://archlinuxjp.github.io/blog/post/docker-arch/

## 概要

このリポジトリではDocker Hubで配布しているイメージがどのように生成されているかを確認することが出来ます。これは一つのシステムを構築しています。具体的には、travis-ciを通して、1日に1度の頻度でこのリポジトリから作成されたdocker in dockerからarchlinuxのイメージを作成し、Docker Hubにpushします。

すべての手順はコマンドラインから実行でき、ローカル環境でも確認できます。

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

docker in dockerでarchlinuxのイメージを作成します。

```bash
$ sudo docker pull archlinuxjp/docker-arch
$ sudo docker run -v /var/run/docker.sock:/var/run/docker.sock --privileged -d -it archlinuxjp/docker-arch /bin/bash
$ export id=`sudo docker ps -q | peco`
$ sudo docker exec $id docker-arch base
$ sudo docker exec $id /bin/bash /mkimage-arch-jp.sh
```

## なぜイメージを日々アップデートするのか?

archlinuxのdocker imageをtravis-ciのcronを介して日々アップデートする理由は、archlinuxのdocker imageがアップデートされずに古くなってしまうことでpacman -Syuができなくなり壊れてしまう危険を回避するためです。

また、当該docker imageを使用する利用者にとっても古いイメージはアップデートに時間がかかってしまい、その辺のタイムロスを縮小する狙いもあります。(dockerfileに最初にpacman -Syuのようなパッケージアップデートの処理を書く人が多いため)

## なぜpacman -Syuでアップデートしないのか?

実はこの仕組は以前、dockerfileに書いた`RUN pacman -Syu`によってアップデートし、それをdocker pushしていた時期がありました。しかし、これではイメージサイズが肥大化していくことがわかり、やり方を変える必要がありました。なぜなら、その処理自体に前日イメージを使用するからです。

ここで、イメージサイズの肥大化を抑えるためには、イメージ生成自体を自動化して、その処理を日々実行することでそれを実現する方法を採用することになりました。なお、この処理、つまり各イメージの生成を実行するスクリプトは`/dockerfile/docker-arch/mkimage-arch/`以下にあります。

## 履歴

2017.01.29 複数あったGitHubリポジトリを`archlinuxjp/docker-arch`に集約しました。 [blog](https://archlinuxjp.github.io/blog/post/docker-arch-2/)

2017.07.27 yaourtのbuild処理が失敗するので一旦無効にしました。[#3](https://github.com/ArchLinuxJP/docker-arch/issues/3)

2017.07.27 docker hubでsource linkがgithubにリンクされており、そのリンクが無効であったため、一旦、当該docker hubのrepositoryを削除後に再度repositoryを作成することにより無効リンクの表示を直しました。 [#4](https://github.com/ArchLinuxJP/docker-arch/issues/4)

