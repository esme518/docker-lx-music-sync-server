#
# Dockerfile for lx-music-sync-server
#

FROM node:16-alpine as builder

WORKDIR /build

RUN set -ex \
    && apk add --update --no-cache \
           git \
           g++ \
           make \
           py3-pip \
    && git clone https://github.com/lyswhut/lx-music-sync-server.git . \
    && git checkout $(git tag | sort -V | tail -1) \
    && npm ci && npm run build \
    && mkdir dst \
    && mv server config.js index.js package-lock.json package.json -t dst \
    && rm -rf /tmp/* /var/cache/apk/*

FROM node:16-alpine
COPY --from=builder /build/dst /server

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
