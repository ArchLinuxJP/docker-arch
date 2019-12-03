現在、Arch Linuxの公式と思われるDocker Imageが日々更新されるようになっています。したがって、このリポジトリ及び、公開していたDocker Imageは役目を終えました。当該イメージは更新されていないので、できれば公式のものをお使いください。

https://hub.docker.com/r/archlinux/base

```
$ docker run -it archlinux/base
```

# docker-arch

[![Build Status](https://travis-ci.org/ArchLinuxJP/docker-archlinux.svg?branch=master)](https://travis-ci.org/ArchLinuxJP/docker-arch)

source : https://github.com/ArchLinuxJP/docker-arch

download : https://hub.docker.com/r/archlinuxjp

Arch LinuxのDockerイメージを[Docker Hub](https://hub.docker.com/r/archlinuxjp)にて配布しています。常に最新のイメージを使用することができます。

これらのDockerイメージは[GitHubリポジトリ](https://github.com/archlinuxjp/docker-arch)からTravis CIでdocker hubにpushされ、`Cron Jobs`の機能によって日々更新されています。

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

以前はdockerfileに書いた`RUN pacman -Syu`によってアップデートしたものをdocker pushしていた時期がありました。しかし、これではイメージサイズが肥大化していくことがわかりました。なぜなら、その処理自体に前日イメージを使用するからです。よって、肥大化を防ぐためにやり方を変える必要がありました。

ここで、イメージサイズの肥大化を抑えるためには、イメージのアプデートではなく、イメージ生成自体を自動化し、その処理を日々実行することでそれを実現する方法を採用することになりました。

なお、この処理、つまり各archlinuxのイメージがどのように生成されているかは、それを実行するスクリプトである`/dockerfile/docker-arch/mkimage-arch/`以下を確認してください。

## archlinuxjp/archlinuxが動作しない場合の直し方

docker-archはエコシステムで回しているので、`FROM archlinuxjp/archlinux`が動作しない場合、なかなか正常に動きません。

このような場合は手動でDocker Hubにpushする必要があります。修正する必要があるのは`FROM archlinuxjp/archlinux`, `FROM archlinuxjp/docker-arch`です。

- まず、archlinuxを起動し、dockerを動かします。

- このリポジトリをクローンして、必要なファイル`mkimage-arch-jp.sh`や`base.sh`などを修正した上で以下を実行します。

```sh
# FROM archlinuxjp/docker-arch
$ git clone https://github.com/archlinuxjp/docker-arch
$ cd docker-arch/dockerfile/docker-arch/bin
$ vim mkimage-arch-jp.sh 
	# ファイルの置き場所を参照します。通常はdocker in dockerの構成になっていますが、手動でやる場合は当該ディレクトリ上のファイルを参照します
	- cp -rf /docker-arch $ROOTFS
	- cp -rf /mkimage-arch $ROOTFS
	+ cp -rf ./docker-arch $ROOTFS
	+ cp -rf ../mkimage-arch $ROOTFS
$ sudo docker build -t archlinuxjp/docker-arch .
$ sudo docker login
$ sudo docker push archlinuxjp/docker-arch

# FROM archlinuxjp/archlinux
$ sudo docker pull archlinuxjp/docker-arch
$ sudo docker run -v /var/run/docker.sock:/var/run/docker.sock --privileged -d -it archlinuxjp/docker-arch /bin/bash
$ export id=`sudo docker ps -q | peco`
$ sudo docker exec $id docker-arch base
$ sudo docker exec $id /bin/bash /mkimage-arch-jp.sh 
$ sudo docker push archlinuxjp/archlinux
```

## travis + slack

```sh
script:
	export text=`docker images`;
	curl -X POST "$SLACK_WEB_URL" -d "payload={\"channel\":\"$SLACK_CHANNEL\", \"username\":\"docker\", \"text\":\"$text\", \"icon_emoji\":\":docker:\"}";

notifications:
  slack:
    secure: j8HSA3jwhQJ9dibD1rFbbBJ7BjefWNXOf5d1b7gMvn/yxiuzMrsxIN3rEXj6V0hHnjAcHHSSVGCZO8MGu9MDfXQHx1AoyxS3i0qLuMGD8EHeuTQJ6usV9pySE4A9A+yGbWh4reKLfqwPcdqy3LKbvaIIYkYzCHTtJw3lgS/dqxGiLgziiz2cUbo8yQaqKyjeXHWX/4xiHXNNSdixJK4KzltfJBYz9BMdT766+cADcLH922CIYdUsjSsPI27O1WA1Fd2sTb63xTn224F2hZTQrIEONLjB0/EWsHiAYXsX8uu3ghLC8mLrwUpF95FD/S8lK+GgrIKPZUyRJCNQf0ET0lnU2RiHAp5K2jOzM4DeN3wthTLdLDiKwt6Sq5RpsN23fBntxyAdMC4sIrgqs4JGKjqGR8Gdl6NrfzxrZF1bsTWWMGOmUzy7nHMKo7J2T2gqI2gDeaX0YJ1C3RSQ+6RymJlalEJx4ywY/9774VQ9CVbYm0DMUG+Xk+MTjWdR5/UErU/XeCne3Qgb0fPyanysVKhvg8dqMEImFDlZUYZxNkEvfGIhXj4kaQYtgdY7J3Or4DXgzK8n5TdUFmMdQo5kL35lOedPxX0T2haIX8Wodlpm2rJwFiJF4ZL4EPCQYfeRPpwfpd1uQTe0C+bLVKGL7illp7VyngCo0INIw6O3rCQ=
```

## 履歴

2017.01.29 複数あったGitHubリポジトリを`archlinuxjp/docker-arch`に集約しました。 [blog](https://archlinuxjp.github.io/blog/post/docker-arch-2/)

2017.07.27 yaourtのbuild処理が失敗するので一旦無効にしました。[#3](https://github.com/ArchLinuxJP/docker-arch/issues/3)

2017.07.27 docker hubでsource linkがgithubにリンクされており、そのリンクが無効であったため、一旦、当該docker hubのrepositoryを削除後に再度repositoryを作成することにより無効リンクの表示を直しました。 [#4](https://github.com/ArchLinuxJP/docker-arch/issues/4)

2017.07.29 travisで10分間出力がない場合に処理を停止する問題(yaourt build時)は`travis_retry`を使うことで解決しました。 [#3](https://github.com/ArchLinuxJP/docker-arch/issues/3)

2017.10.22 mirrorの不具合が2日連続で出ていたので`ftp.tsukuba.wide.ad.jp -> http://mirror.archlinux.jp`に変更しました。[link](https://www.archlinux.jp/mirrors/status/)

2018.04.12 この日からtravisでbuildが失敗するようになりました。`There was an error while trying to fetch the log.`でログを表示することもできません。 解決済み

2019.01.25 `mkimage-arch.sh`が動作しなくなりました。よって、イメージが最新版ではなくなっています。`ERROR: failed to setup chroot`. [issue](https://github.com/ArchLinuxJP/docker-arch/issues/7)
