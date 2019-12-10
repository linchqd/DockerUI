FROM node:12.13.1

RUN git clone -b web https://github.com/linchqd/DockerUI.git /tmp/web && \
    git clone -b api https://github.com/linchqd/DockerUI.git /tmp/dockerui/api

WORKDIR /tmp/web

RUN npm config set registry https://registry.npm.taobao.org && \
    npm install && \
    npm run build && \
    mv /tmp/web/dist /tmp/dockerui/web


FROM centos:centos7

RUN yum -y install --setopt=tsflags=nodocs epel-release && \
    yum -y install wget nginx supervisor redhat-lsb-core net-tools vim openssl-devel bzip2-devel expat-devel \
    gdbm-devel readline-devel sqlite-devel gcc unzip libffi-devel lzma zlib-devel openssl-static \
    ncurses-devel readline-devel tk-devel db4-devel libpcap-devel xz-devel && \
    yum clean all

RUN cd /usr/local/src/ && \
    wget http://10.0.2.15/Python-3.7.5.tgz && \
#    wget https://www.python.org/ftp/python/3.7.5/Python-3.7.5.tgz && \
    tar zxvf Python-3.7.5.tgz && \
    cd Python-3.7.5 && \
    ./configure --prefix=/usr/local/python3 --enable-optimizations && \
    make && \
    make install && \
    cd .. && \
    ln -s /usr/local/python3/bin/* /usr/local/bin/ && \
    rm -rf Python-3.7.5 Python-3.7.5.tgz

RUN mkdir /dockerui

COPY --from=0 /tmp/dockerui /dockerui

COPY . /dockerui

RUN chmod +x /dockerui/entrypoint.sh && \
    mv nginx.conf /etc/nginx/nginx.conf && \
    mv supervisord.conf /etc/supervisord.conf && \
    mv supervisor_gunicorn.ini /etc/supervisord.d/supervisor_gunicorn.ini

ENTRYPOINT ["/dockerui/entrypoint.sh"]
