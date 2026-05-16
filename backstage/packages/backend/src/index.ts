import { createBackend } from '@backstage/backend-defaults';

const backend = createBackend();

const FEATURE_TYPE = '@backstage/BackendFeature';

const isFeature = (val: unknown): boolean =>
  !!val &&
  (typeof val === 'object' || typeof val === 'function') &&
  (val as any).$$type === FEATURE_TYPE;

const findFeature = (mod: any): { key: string; val: any } | undefined => {
  for (const [key, val] of Object.entries(mod as object)) {
    if (isFeature(val)) return { key, val };
  }
  return undefined;
};

// Each plugin tries `/alpha` first (where the new backend system lives in
// older Backstage releases), then falls back to the main export.
const plugins: Array<[string, () => Promise<any>, () => Promise<any>]> = [
  ['app-backend',
    () => import('@backstage/plugin-app-backend/alpha'),
    () => import('@backstage/plugin-app-backend')],
  ['catalog-backend',
    () => import('@backstage/plugin-catalog-backend/alpha'),
    () => import('@backstage/plugin-catalog-backend')],
  ['catalog-backend-module-github',
    () => import('@backstage/plugin-catalog-backend-module-github/alpha'),
    () => import('@backstage/plugin-catalog-backend-module-github')],
  ['auth-backend',
    () => import('@backstage/plugin-auth-backend/alpha'),
    () => import('@backstage/plugin-auth-backend')],
  ['auth-backend-module-github',
    () => import('@backstage/plugin-auth-backend-module-github-provider'),
    () => import('@backstage/plugin-auth-backend-module-github-provider')],
  ['proxy-backend',
    () => import('@backstage/plugin-proxy-backend/alpha'),
    () => import('@backstage/plugin-proxy-backend')],
  ['scaffolder-backend',
    () => import('@backstage/plugin-scaffolder-backend/alpha'),
    () => import('@backstage/plugin-scaffolder-backend')],
  ['techdocs-backend',
    () => import('@backstage/plugin-techdocs-backend/alpha'),
    () => import('@backstage/plugin-techdocs-backend')],
  ['search-backend',
    () => import('@backstage/plugin-search-backend/alpha'),
    () => import('@backstage/plugin-search-backend')],
  ['search-backend-module-catalog',
    () => import('@backstage/plugin-search-backend-module-catalog/alpha'),
    () => import('@backstage/plugin-search-backend-module-catalog')],
  ['kubernetes-backend',
    () => import('@backstage/plugin-kubernetes-backend/alpha'),
    () => import('@backstage/plugin-kubernetes-backend')],
];

(async () => {
  for (const [name, primary, fallback] of plugins) {
    let mod: any;
    let source = 'alpha';
    try {
      mod = await primary();
    } catch (err: any) {
      process.stderr.write(
        `[plugin-load] alpha-miss ${name}: ${err?.code ?? ''} ${err?.message ?? err}\n`,
      );
      try {
        mod = await fallback();
        source = 'main';
      } catch (err2: any) {
        process.stderr.write(
          `[plugin-load] FAIL ${name}: ${err2?.code ?? ''} ${err2?.message ?? err2}\n`,
        );
        continue;
      }
    }

    const found = findFeature(mod);
    if (!found) {
      const summary = Object.entries(mod as object)
        .map(([k, v]) => `${k}=${typeof v}:$$type=${(v as any)?.$$type ?? 'n/a'}`)
        .join(' | ');
      process.stderr.write(
        `[plugin-load] SKIP ${name} (${source}): no BackendFeature — ${summary}\n`,
      );
      continue;
    }

    backend.add(found.val);
    process.stderr.write(
      `[plugin-load] OK   ${name} (${source}.${found.key})\n`,
    );
  }

  backend.start();
})();
