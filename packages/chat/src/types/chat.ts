/**
 * Chat type definitions
 */

/** Tool call status for activity timeline display */
export interface ToolCall {
  id: string;
  name: string;
  args: Record<string, unknown>;
  status: 'pending' | 'running' | 'complete' | 'error';
  result?: unknown;
}

/** Configuration for the chat runtime */
export interface ChatConfig {
  /** Base URL for the chat API proxy (e.g., '/api/v1' or 'http://localhost:8081/api/v1') */
  apiBaseUrl: string;
  /** Default LangGraph assistant ID */
  assistantId?: string;
}
