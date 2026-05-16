import { createBackend } from '@backstage/backend-defaults';

const backend = createBackend();

const plugins: Array<[string, () => Promise<any>]> = [
  ['app-backend',                   () => import('@backstage/plugin-app-backend')],
  ['catalog-backend',               () => import('@backstage/plugin-catalog-backend')],
  ['catalog-backend-module-github', () => import('@backstage/plugin-catalog-backend-module-github')],
  ['auth-backend',                  () => import('@backstage/plugin-auth-backend')],
  ['auth-backend-module-github',    () => import('@backstage/plugin-auth-backend-module-github-provider')],
  ['proxy-backend',                 () => import('@backstage/plugin-proxy-backend')],
  ['scaffolder-backend',            () => import('@backstage/plugin-scaffolder-backend')],
  ['techdocs-backend',              () => import('@backstage/plugin-techdocs-backend')],
  ['search-backend',                () => import('@backstage/plugin-search-backend')],
  ['search-backend-module-catalog', () => import('@backstage/plugin-search-backend-module-catalog')],
  ['kubernetes-backend',            () => import('@backstage/plugin-kubernetes-backend')],
];

(async () => {
  for (const [name, loader] of plugins) {
    try {
      const mod: any = await loader();
      const feature = mod?.default;
      if (!feature) {
        process.stderr.write(
          `[plugin-load] SKIP ${name}: default export is ${typeof feature} (exports: ${Object.keys(mod).join(',')})\n`,
        );
        continue;
      }
      backend.add(feature);
      process.stderr.write(`[plugin-load] OK   ${name}\n`);
    } catch (err: any) {
      process.stderr.write(
        `[plugin-load] FAIL ${name}: ${err?.code ?? ''} ${err?.message ?? err}\n`,
      );
    }
  }
  backend.start();
})();
