FROM node:12.13.1

RUN git clone -b web https://github.com/linchqd/DockerUI.git /tmp/web && \
    git clone -b api https://github.com/linchqd/DockerUI.git /tmp/dockerui/api

WORKDIR /tmp/web

RUN npm config set registry https://registry.npm.taobao.org && \
    npm install && \
    npm run build && \
    mv /tmp/web/dist /tmp/dockerui/web


FROM linchqd/python:v3.7.5

RUN mkdir /dockerui

COPY --from=0 /tmp/dockerui /dockerui

COPY ./ /dockerui

RUN cd /dockerui/api/ && \
    pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/  && \
    pip3 install --upgrade pip && \
    pip3 install --no-cache-dir -r requirements.txt && \
    pip3 install --no-cache-dir supervisor gunicorn gevent && \
    ln -s /usr/local/python3/bin/gunicorn /usr/local/bin/ && \
    ln -s /usr/local/python3/bin/supervisor* /usr/local/bin/

RUN chmod +x /dockerui/entrypoint.sh && \
    mv /dockerui/nginx.conf /etc/nginx/nginx.conf && \
    mv /dockerui/supervisord.conf /etc/supervisord.conf && \
    mkdir /etc/supervisord.d/ && \
    mv /dockerui/supervisor_gunicorn.ini /etc/supervisord.d/supervisor_gunicorn.ini

ENTRYPOINT ["/dockerui/entrypoint.sh"]
