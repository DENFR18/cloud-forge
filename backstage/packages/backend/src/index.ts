import { createBackend } from '@backstage/backend-defaults';

const backend = createBackend();

backend.add(import('@backstage/plugin-app-backend'));
// catalog-backend@3.6.1 requires serviceRef{alpha.core.metrics} which is not
// provided by backend-defaults@0.14.2 — disabled until a compatible metrics
// service is wired up
// backend.add(import('@backstage/plugin-catalog-backend'));
// backend.add(import('@backstage/plugin-catalog-backend-module-github'));
backend.add(import('@backstage/plugin-auth-backend'));
backend.add(import('@backstage/plugin-auth-backend-module-github-provider'));
backend.add(import('@backstage/plugin-proxy-backend'));
backend.add(import('@backstage/plugin-scaffolder-backend'));
backend.add(import('@backstage/plugin-techdocs-backend'));
backend.add(import('@backstage/plugin-search-backend'));
// search-backend-module-catalog depends on catalog-backend, disabled with it
// backend.add(import('@backstage/plugin-search-backend-module-catalog'));
backend.add(import('@backstage/plugin-kubernetes-backend'));

backend.start();
