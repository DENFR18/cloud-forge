import React from 'react';
import { Navigate, Route } from 'react-router-dom';

import { apiDocsPlugin, ApiExplorerPage } from '@backstage/plugin-api-docs';
import {
  CatalogEntityPage,
  CatalogIndexPage,
  catalogPlugin,
} from '@backstage/plugin-catalog';
import { ScaffolderPage, scaffolderPlugin } from '@backstage/plugin-scaffolder';
import { orgPlugin } from '@backstage/plugin-org';
import { SearchPage } from '@backstage/plugin-search';
import {
  TechDocsIndexPage,
  TechDocsReaderPage,
  techdocsPlugin,
} from '@backstage/plugin-techdocs';
import { UserSettingsPage } from '@backstage/plugin-user-settings';
import { AlertDisplay, OAuthRequestDialog, SignInPage } from '@backstage/core-components';
import { githubAuthApiRef } from '@backstage/core-plugin-api';
import { createApp } from '@backstage/app-defaults';
import { AppRouter, FlatRoutes } from '@backstage/core-app-api';
import { CatalogGraphPage } from '@backstage/plugin-catalog-react';

const app = createApp({
  bindRoutes({ bind }) {
    bind(catalogPlugin.externalRoutes, {
      createComponent: scaffolderPlugin.routes.root,
      viewTechDoc: techdocsPlugin.routes.docRoot,
      createFromTemplate: scaffolderPlugin.routes.selectedTemplate,
    });
    bind(apiDocsPlugin.externalRoutes, {
      registerApi: { path: '/catalog-import' } as any,
    });
    bind(orgPlugin.externalRoutes, {
      catalogIndex: catalogPlugin.routes.catalogIndex,
    });
  },
  components: {
    SignInPage: props => (
      <SignInPage
        {...props}
        auto
        provider={{
          id: 'github-auth-provider',
          title: 'GitHub',
          message: 'Sign in with GitHub',
          apiRef: githubAuthApiRef,
        }}
      />
    ),
  },
});

export default app.createRoot(
  <>
    <AlertDisplay />
    <OAuthRequestDialog />
    <AppRouter>
      <FlatRoutes>
        <Route path="/" element={<Navigate to="catalog" />} />
        <Route path="/catalog" element={<CatalogIndexPage />} />
        <Route
          path="/catalog/:namespace/:kind/:name"
          element={<CatalogEntityPage />}
        />
        <Route path="/docs" element={<TechDocsIndexPage />} />
        <Route
          path="/docs/:namespace/:kind/:name/*"
          element={<TechDocsReaderPage />}
        />
        <Route path="/create" element={<ScaffolderPage />} />
        <Route path="/api-docs" element={<ApiExplorerPage />} />
        <Route path="/search" element={<SearchPage />} />
        <Route path="/settings" element={<UserSettingsPage />} />
        <Route path="/catalog-graph" element={<CatalogGraphPage />} />
      </FlatRoutes>
    </AppRouter>
  </>,
);
