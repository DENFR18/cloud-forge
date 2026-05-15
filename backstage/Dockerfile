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

# Diagnostics: what does the build actually produce?
RUN echo "=== packages/backend/dist/ ===" && ls -la packages/backend/dist/ && \
    echo "=== Is index.cjs.js standalone? ===" && \
    (test -f packages/backend/dist/index.cjs.js && echo "YES standalone" || echo "NO - inside bundle.tar.gz") && \
    echo "=== bundle.tar.gz first 20 entries ===" && \
    tar tzf packages/backend/dist/bundle.tar.gz | head -20

# Stage 2 – runtime
FROM node:22-alpine

RUN apk add --no-cache python3 py3-pip && \
    pip3 install mkdocs-techdocs-core --break-system-packages

WORKDIR /app

# Copy the entire build workspace
COPY --from=build /app ./

# Extract bundle.tar.gz unconditionally to guarantee packages/backend/dist/index.cjs.js
# exists at the runtime entrypoint path. The extraction will overwrite node_modules
# with production-only deps, so we then explicitly recreate node_modules/app as a
# symlink to packages/app — plugin-app-backend needs require('app/package.json')
# to resolve in order to locate the frontend dist.
RUN tar xzf packages/backend/dist/bundle.tar.gz && \
    rm -f packages/backend/dist/bundle.tar.gz packages/backend/dist/skeleton.tar.gz && \
    rm -rf node_modules/app && \
    ln -s /app/packages/app /app/node_modules/app && \
    echo "=== Runtime dist/ ===" && ls -la packages/backend/dist/ && \
    echo "=== Runtime node_modules/app ===" && ls -la node_modules/app && \
    echo "=== Runtime packages/app/dist ===" && ls packages/app/dist | head -5

EXPOSE 7007

ENV NODE_ENV=production

CMD ["node", "packages/backend/dist/index.cjs.js"]
