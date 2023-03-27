#
# Dockerfile for lx-music-sync-server
#

FROM alpine as source

ARG URL=https://api.github.com/repos/lyswhut/lx-music-sync-server/releases/latest

WORKDIR /server

RUN set -ex \
    && apk add --update --no-cache curl \
    && wget -O server.zip $(curl -s $URL | grep browser_download_url | egrep -o "https.+\.zip") \
    && unzip server.zip && rm server.zip

FROM node:16-alpine
COPY --from=source /server /server

WORKDIR /server
VOLUME /server/data

RUN set -ex \
    && apk add --update --no-cache --virtual .gyp \
           g++ \
           make \
           py3-pip \
    && npm ci --omit=dev \
    && apk del .gyp \
    && rm -rf /tmp/* /var/cache/apk/*

ENV NODE_ENV 'production'
ENV LOG_PATH '/server/data/logs'

ENV PORT 9527
ENV BIND_IP '0.0.0.0'
# ENV PROXY_HEADER 'x-real-ip'
# ENV SERVER_NAME 'My Sync Server'
# ENV MAX_SNAPSHOT_NUM '10'
# ENV LIST_ADD_MUSIC_LOCATION_TYPE 'top'
# ENV LX_USER_user1 '123.123'
# ENV LX_USER_user2 '{ "password": "123.456", "maxSnapshotNum": 10, "list.addMusicLocationType": "top" }'

EXPOSE 9527

CMD ["npm","start"]
