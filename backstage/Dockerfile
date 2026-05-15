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

RUN echo "=== backend dist contents ===" && ls -la /app/packages/backend/dist/

# Stage 2 – runtime
FROM node:22-alpine

RUN apk add --no-cache python3 py3-pip && \
    pip3 install mkdocs-techdocs-core --break-system-packages

WORKDIR /app

# Backend build artifacts (new Backstage backend build format: tarballs)
COPY --from=build /app/packages/backend/dist/skeleton.tar.gz ./packages/backend/dist/skeleton.tar.gz
COPY --from=build /app/packages/backend/dist/bundle.tar.gz ./packages/backend/dist/bundle.tar.gz

# yarn.lock for deterministic production install
COPY --from=build /app/yarn.lock ./

# Restore workspace package.json hierarchy from skeleton, then install production deps
RUN tar xzf packages/backend/dist/skeleton.tar.gz && \
    rm packages/backend/dist/skeleton.tar.gz && \
    yarn install --production --no-frozen-lockfile --network-timeout 600000 && \
    rm -rf "$(yarn cache dir)"

# Extract the backend bundle (produces packages/backend/dist/index.cjs.js)
RUN tar xzf packages/backend/dist/bundle.tar.gz && \
    rm packages/backend/dist/bundle.tar.gz

# Frontend static assets served by @backstage/plugin-app-backend
COPY --from=build /app/packages/app/dist ./packages/app/dist

COPY app-config.yaml ./app-config.yaml
COPY catalog-info.yaml ./catalog-info.yaml

EXPOSE 7007

ENV NODE_ENV=production

CMD ["sh", "-c", "ls -la packages/backend/dist/ && node packages/backend/dist/index.cjs.js"]
