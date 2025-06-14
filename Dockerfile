# 1) build your wheel in a builder image
FROM python:3.11-slim AS builder

WORKDIR /md
COPY . .

RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential \
 && pip install --no-cache-dir --upgrade pip setuptools wheel \
 && pip wheel . -w /wheels \
 && apt-get purge -y build-essential \
 && rm -rf /var/lib/apt/lists/*

# 2) final image only needs runtime + ffmpeg + your wheel
FROM python:3.11-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends ffmpeg \
 && rm -rf /var/lib/apt/lists/*

COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir /wheels/*.whl

ENTRYPOINT ["moodle-dl", "--path", "/files"]
