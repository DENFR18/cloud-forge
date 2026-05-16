import { createBackend } from '@backstage/backend-defaults';

const backend = createBackend();

// Wrap dynamic imports so any failure (missing /alpha subpath, peer dep,
// plugin construction error) is logged explicitly to stderr instead of
// being swallowed silently by backend.add()'s Promise handling.
const safeAdd = (name: string, loader: () => Promise<unknown>) => {
  backend.add(
    loader()
      .then(mod => {
        process.stderr.write(`[plugin-load] OK   ${name}\n`);
        return mod as { default: unknown };
      })
      .catch(err => {
        process.stderr.write(
          `[plugin-load] FAIL ${name}: ${err?.code ?? ''} ${err?.message ?? err}\n`,
        );
        // Return a no-op feature so backend.add() doesn't choke
        return { default: { $$type: '@backstage/BackendFeature' as const, version: 'v1' as const, getRegistrations: () => [] } };
      }) as Promise<{ default: any }>,
  );
};

safeAdd('app-backend',                       () => import('@backstage/plugin-app-backend'));
safeAdd('catalog-backend',                   () => import('@backstage/plugin-catalog-backend'));
safeAdd('catalog-backend-module-github',     () => import('@backstage/plugin-catalog-backend-module-github'));
safeAdd('auth-backend',                      () => import('@backstage/plugin-auth-backend'));
safeAdd('auth-backend-module-github',        () => import('@backstage/plugin-auth-backend-module-github-provider'));
safeAdd('proxy-backend',                     () => import('@backstage/plugin-proxy-backend'));
safeAdd('scaffolder-backend',                () => import('@backstage/plugin-scaffolder-backend'));
safeAdd('techdocs-backend',                  () => import('@backstage/plugin-techdocs-backend'));
safeAdd('search-backend',                    () => import('@backstage/plugin-search-backend'));
safeAdd('search-backend-module-catalog',     () => import('@backstage/plugin-search-backend-module-catalog'));
safeAdd('kubernetes-backend',                () => import('@backstage/plugin-kubernetes-backend'));

backend.start();
