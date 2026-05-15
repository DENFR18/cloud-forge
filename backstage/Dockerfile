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

RUN yarn install --production --no-frozen-lockfile --network-timeout 600000

# Stage 2 – runtime
FROM node:22-alpine

RUN apk add --no-cache python3 py3-pip && \
    pip3 install mkdocs-techdocs-core --break-system-packages

WORKDIR /app

COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/packages/backend/dist ./packages/backend/dist
COPY --from=build /app/packages/backend/node_modules ./packages/backend/node_modules

COPY app-config.yaml ./app-config.yaml
COPY catalog-info.yaml ./catalog-info.yaml

EXPOSE 7007

ENV NODE_ENV=production

CMD ["sh", "-c", "for f in packages/backend/dist/index.cjs.js packages/backend/dist/index.js packages/backend/dist/index.cjs; do if [ -f \"$f\" ]; then exec node \"$f\"; fi; done; echo 'ERROR: no backend entry found in dist/'; ls -la packages/backend/dist/; exit 1"]
