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

# Extract the backend bundle in the build stage (produces index.cjs.js from bundle.tar.gz)
RUN tar xzf packages/backend/dist/bundle.tar.gz && \
    rm packages/backend/dist/bundle.tar.gz packages/backend/dist/skeleton.tar.gz && \
    echo "=== backend dist ===" && ls -la packages/backend/dist/

# Stage 2 – runtime
FROM node:22-alpine

RUN apk add --no-cache python3 py3-pip && \
    pip3 install mkdocs-techdocs-core --break-system-packages

WORKDIR /app

# Production node_modules (hoisted workspace deps)
COPY --from=build /app/node_modules ./node_modules

# Compiled backend entry point
COPY --from=build /app/packages/backend/dist ./packages/backend/dist
COPY --from=build /app/packages/backend/node_modules ./packages/backend/node_modules

# Frontend static assets served by @backstage/plugin-app-backend
COPY --from=build /app/packages/app/dist ./packages/app/dist

COPY app-config.yaml ./app-config.yaml
COPY catalog-info.yaml ./catalog-info.yaml

EXPOSE 7007

ENV NODE_ENV=production

CMD ["node", "packages/backend/dist/index.cjs.js"]
