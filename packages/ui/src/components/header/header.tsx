import { Link } from '@tanstack/react-router';
import { Logo } from '../logo/logo';
import { ModeToggle } from '../mode-toggle/mode-toggle';

export function Header() {
  return (
    <header className="sticky top-0 z-20 border-b bg-background/80 backdrop-blur">
      <div className="container mx-auto flex h-16 max-w-7xl items-center justify-between px-4 sm:px-6 lg:px-8">
        <div className="flex items-center gap-6">
          <Link to="/" className="flex items-center gap-2">
            <Logo />
            <span className="font-bold">dagshub-ai-dev-plaform-support</span>
          </Link>
          <nav className="flex items-center gap-4">
            <Link to="/chat" className="text-sm font-medium text-muted-foreground transition-colors hover:text-foreground">
              Chat
            </Link>
          </nav>
        </div>
        <div className="flex items-center gap-4">
          <ModeToggle />
        </div>
      </div>
    </header>
  );
}
