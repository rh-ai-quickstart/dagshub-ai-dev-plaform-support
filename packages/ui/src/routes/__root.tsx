// dagshub-ai-dev-plaform-support - Root Route
// React import required for JSX (ESLint requirement)
// @ts-expect-error - React is used implicitly by JSX transform
import React from 'react';
import { createRootRoute, Outlet } from '@tanstack/react-router';
import { TanStackRouterDevtools } from '@tanstack/router-devtools';
import { Header } from '../components/header/header';
import { Footer } from '../components/footer/footer';

export const Route = createRootRoute({
  component: () => (
    <div className="flex h-screen flex-col">
      <Header />
      <main className="relative min-h-0 flex-1 overflow-y-auto">
        <Outlet />
      </main>
      <Footer />
      <TanStackRouterDevtools />
    </div>
  ),
});