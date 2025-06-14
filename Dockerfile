// Dockerfile
# 1) build your wheel on slim
FROM python:3.11-slim AS python-builder
WORKDIR /src
COPY . .
RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential \
 && pip install --no-cache-dir wheel setuptools \
 && pip wheel . -w /wheels \
 && apt-get purge -y build-essential \
 && rm -rf /var/lib/apt/lists/*

# 2) grab a tiny, static ffmpeg from an Alpine ffmpeg image
FROM jrottenberg/ffmpeg:4.4-alpine AS ffmpeg-builder

# 3) assemble final image
FROM python:3.11-slim
# install only python runtime
RUN apt-get update \
 && rm -rf /var/lib/apt/lists/*

# install your package
COPY --from=python-builder /wheels /wheels
RUN pip install --no-cache-dir /wheels/*.whl

# copy the static ffmpeg binary
COPY --from=ffmpeg-builder /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg

ENTRYPOINT ["moodle-dl","--path","/files"]
