FROM debian:latest

MAINTAINER akahana_1<aakahana@gmail.com>
LABEL Desciption="tex build environment using (u)pLaTeX with Adobe Source Han Fonts"

ARG REPOSITORY="http://ftp.jaist.ac.jp/pub/CTAN/systems/texlive/tlnet/"
ARG INSTALLER="install-tl-unx.tar.gz"
ARG PROFILE="https://gist.github.com/akahana-1/44bb19536bbffc0dba25229b731ffdaf/raw/175706892f0e476f9aa6d24c6c45784fcdf1d2cd/texlive.profile"
ARG TL_VERSION="2017"

RUN set -x \
	&& apt update \
	&& apt dist-upgrade -y \
	&& apt install --no-install-recommends -y \
		wget perl fontconfig libwww-perl unzip \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& wget ${REPOSITORY}${INSTALLER} \
	&& tar xvf ${INSTALLER} \
	&& wget ${PROFILE} \
	&& ./install-tl-*/install-tl -profile texlive.profile -repository ${REPOSITORY} \
	&& export PATH=/usr/local/texlive/${TL_VERSION}/bin/x86_64-linux:${PATH} \
	&& tlmgr init-usertree \
	&& tlmgr update --self --all \
	&& cp $(kpsewhich -var-value TEXMFSYSVAR)/fonts/conf/texlive-fontconfig.conf /etc/fonts/conf.d/09-texlive.conf \
# フォントの整備
	&& cd /tmp \
	&& wget https://github.com/adobe-fonts/source-han-sans/raw/release/OTC/SourceHanSansOTC_M-H.zip \
	&& wget https://github.com/adobe-fonts/source-han-sans/raw/release/OTC/SourceHanSansOTC_EL-R.zip \
	&& wget https://github.com/adobe-fonts/source-han-serif/raw/release/OTC/SourceHanSerifOTC_EL-M.zip \
	&& wget https://github.com/adobe-fonts/source-han-serif/raw/release/OTC/SourceHanSerifOTC_SB-H.zip \
# unzipでglobを指定するときはエスケープが必要
	&& unzip SourceHan\*.zip \
# RUNはsh -cで走るのでbash拡張が使えない
	&& mkdir -p $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype/adobe/sourcehanserif \
	&& mkdir -p $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype/adobe/sourcehansans \
	&& mv SourceHanSansOTC*/*.ttc $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype/adobe/sourcehansans/ \
	&& mv SourceHanSerifOTC*/*.ttc $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype/adobe/sourcehanserif/ \
	&& fc-cache -fsv \
# Takayuki YATO氏によるライブラリのインストール
# PXchfon
# 常に最新版が欲しいのでなければ`tlmgr install pxchfon`で問題ない
#	&& wget https://github.com/zr-tex8r/PXchfon/archive/master.zip -O PXchfon.zip \
#	&& unzip PXchfon.zip \
#	&& mkdir -p $(kpsewhich -var-value TEXMFLOCAL)/tex/platex/pxchfon \
#	&& mkdir -p $(kpsewhich -var-value TEXMFLOCAL)/fonts/tfm/public/pxchfon \
#	&& mkdir -p $(kpsewhich -var-value TEXMFLOCAL)/fonts/vf/public/pxchfon \
#	&& mkdir -p $(kpsewhich -var-value TEXMFLOCAL)/fonts/sfd/pxchfon \
#	&& mv PXchfon*/*.sty $(kpsewhich -var-value TEXMFLOCAL)/tex/platex/pxchfon \
#	&& mv PXchfon*/*.tfm $(kpsewhich -var-value TEXMFLOCAL)/fonts/tfm/public/pxchfon \
#	&& mv PXchfon*/*.vf $(kpsewhich -var-value TEXMFLOCAL)/fonts/vf/public/pxchfon \
#	&& mv PXchfon*/*.sfd $(kpsewhich -var-value TEXMFLOCAL)/fonts/sfd/pxchfon \
#	&& mv PXchfon*/*.def $(kpsewhich -var-value TEXMFLOCAL)/tex/platex/pxchfon \
#	&& mktexlsr \
	&& tlmgr install pxchfon \
# クリーニング
	&& cd / \
	&& rm -rf /tmp/* \
	&& rm -rf install-tl*

WORKDIR /root

COPY .latexmkrc /root/.latexmkrc

CMD [ "/bin/bash" ]
