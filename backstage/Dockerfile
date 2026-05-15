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

# Diagnostic: confirm both the frontend bundle and the workspace symlink exist
RUN echo "=== packages/app/dist ===" && ls -la packages/app/dist && \
    echo "=== packages/backend/dist ===" && ls -la packages/backend/dist && \
    echo "=== node_modules/app symlink ===" && ls -la node_modules/app && \
    echo "=== node_modules/@backstage/plugin-app-backend ===" && \
    ls -la node_modules/@backstage/plugin-app-backend && \
    echo "=== plugin-app-backend version ===" && \
    cat node_modules/@backstage/plugin-app-backend/package.json | grep '"version"'

# Stage 2 – runtime
FROM node:22-alpine

RUN apk add --no-cache python3 py3-pip && \
    pip3 install mkdocs-techdocs-core --break-system-packages

WORKDIR /app

# Copy the entire workspace (preserves yarn workspace symlinks and all packages).
# Using a single COPY keeps node_modules/<workspace-package> symlinks pointing at
# packages/<name>, which plugin-app-backend needs to resolve via require().
COPY --from=build /app ./

EXPOSE 7007

ENV NODE_ENV=production

CMD ["node", "packages/backend/dist/index.cjs.js"]
