import { createBackend } from '@backstage/backend-defaults';

const backend = createBackend();

const FEATURE_TYPE = '@backstage/BackendFeature';

const isFeature = (val: unknown): boolean =>
  !!val &&
  (typeof val === 'object' || typeof val === 'function') &&
  (val as any).$$type === FEATURE_TYPE;

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
      const entries = Object.entries(mod as object);

      // Search all exports for a BackendFeature (default first, then named)
      let found: { key: string; val: any } | undefined;
      for (const [key, val] of entries) {
        if (isFeature(val)) {
          found = { key, val };
          break;
        }
      }

      if (!found) {
        const summary = entries
          .map(([k, v]) => `${k}=${typeof v}:$$type=${(v as any)?.$$type ?? 'n/a'}`)
          .join(' | ');
        process.stderr.write(`[plugin-load] SKIP ${name}: no BackendFeature found — ${summary}\n`);
        continue;
      }

      backend.add(found.val);
      process.stderr.write(
        `[plugin-load] OK   ${name} (export: ${found.key})\n`,
      );
    } catch (err: any) {
      process.stderr.write(
        `[plugin-load] FAIL ${name}: ${err?.code ?? ''} ${err?.message ?? err}\n`,
      );
    }
  }

  backend.start();
})();
