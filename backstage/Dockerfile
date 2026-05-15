# Stage 1 – build (TypeScript backend + Vite frontend)
FROM node:22-alpine AS build

RUN apk add --no-cache python3 make g++

WORKDIR /app

COPY package.json yarn.lock ./
COPY packages/app/package.json ./packages/app/package.json
COPY packages/backend/package.json ./packages/backend/package.json

RUN yarn install --no-frozen-lockfile --network-timeout 600000

COPY . .

RUN yarn workspace app build
RUN yarn workspace backend build

# Show build output for diagnostics
RUN echo "=== packages/backend/dist ===" && ls -la packages/backend/dist/ && \
    echo "=== index.cjs.js standalone ===" && (test -f packages/backend/dist/index.cjs.js && echo "EXISTS" || echo "NOT FOUND – is inside bundle.tar.gz") && \
    echo "=== bundle.tar.gz contents (first 30 lines) ===" && tar tzf packages/backend/dist/bundle.tar.gz | head -30 && \
    echo "=== node_modules/app ===" && ls -la node_modules/app && \
    echo "=== packages/app/dist ===" && ls -la packages/app/dist | head -5

# Stage 2 – runtime
FROM node:22-alpine

RUN apk add --no-cache python3 py3-pip && \
    pip3 install mkdocs-techdocs-core --break-system-packages

WORKDIR /app

# Copy full workspace from build.
# Docker COPY follows symlinks, so node_modules/app becomes a real directory
# containing all files from packages/app (including dist/ and package.json).
# This makes require('app/package.json') resolvable for plugin-app-backend.
COPY --from=build /app ./

# Extract bundle.tar.gz using -k (keep-old-files) so existing files from
# the COPY above are NOT overwritten. This provides index.cjs.js (which is
# not produced as a standalone file by backstage-cli) without corrupting
# the node_modules/app directory that plugin-app-backend relies on.
RUN tar xzf packages/backend/dist/bundle.tar.gz -k 2>/dev/null; \
    rm -f packages/backend/dist/bundle.tar.gz packages/backend/dist/skeleton.tar.gz && \
    echo "=== dist after extraction ===" && ls -la packages/backend/dist/ && \
    echo "=== node_modules/app after extraction ===" && ls packages/backend/../node_modules/app | head -5

EXPOSE 7007

ENV NODE_ENV=production

CMD ["node", "packages/backend/dist/index.cjs.js"]
