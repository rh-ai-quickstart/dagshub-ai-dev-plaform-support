/**
 * Chat package public API
 *
 * This package exports React components for AI chat, powered by assistant-ui.
 * The Fastify server (src/server/) proxies requests to the AI agent backend.
 *
 * Usage in the UI package:
 *   import { ChatPage } from '@<project>/chat';
 *
 * Customization:
 *   Run `npx assistant-ui add thread thread-list` in packages/ui
 *   to scaffold pre-styled chat components, then integrate them
 *   into ChatPage or use them directly.
 *
 * @see https://www.assistant-ui.com/docs
 */

export { ChatPage } from './components/ChatPage.js';
export type { ChatConfig, ToolCall } from './types/chat.js';
