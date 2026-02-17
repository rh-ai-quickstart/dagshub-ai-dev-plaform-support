'use client';

import { useRef, useCallback } from 'react';
import {
  AssistantRuntimeProvider,
} from '@assistant-ui/react';
import { useLangGraphRuntime } from '@assistant-ui/react-langgraph';
import { LangChainMessage } from '@assistant-ui/react-langgraph';
import { Client } from '@langchain/langgraph-sdk';
import type { ChatConfig } from '../types/chat.js';

const DEFAULT_CONFIG: ChatConfig = {
  apiBaseUrl: '/api/v1',
  assistantId: 'agent',
};

function createClient(apiBaseUrl: string) {
  return new Client({ apiUrl: apiBaseUrl });
}

async function createThread(client: Client) {
  const thread = await client.threads.create();
  return { externalId: thread.thread_id };
}

async function getThreadState(client: Client, threadId: string) {
  const state = await client.threads.getState(threadId);
  return {
    messages: (state.values as Record<string, LangChainMessage[]>).messages ?? [],
  };
}

async function sendMessage(
  client: Client,
  params: {
    threadId: string;
    messages: LangChainMessage[];
    assistantId: string;
  }
) {
  return client.runs.stream(params.threadId, params.assistantId, {
    input: { messages: params.messages },
    streamMode: 'messages',
  });
}

interface ChatPageProps {
  config?: Partial<ChatConfig>;
  children?: React.ReactNode;
}

export function ChatPage({ config: userConfig, children }: ChatPageProps) {
  const config = { ...DEFAULT_CONFIG, ...userConfig };
  const clientRef = useRef(createClient(config.apiBaseUrl));

  const stream = useCallback(
    async (messages: LangChainMessage[], { initialize }: { initialize: () => Promise<{ externalId?: string }> }) => {
      const { externalId } = await initialize();
      if (!externalId) throw new Error('Thread initialization failed: no externalId');
      return sendMessage(clientRef.current, {
        threadId: externalId,
        messages,
        assistantId: config.assistantId ?? 'agent',
      });
    },
    [config.assistantId]
  );

  const create = useCallback(async () => {
    return createThread(clientRef.current);
  }, []);

  const load = useCallback(async (externalId: string) => {
    return getThreadState(clientRef.current, externalId);
  }, []);

  const runtime = useLangGraphRuntime({
    stream,
    create,
    load,
  });

  return (
    <AssistantRuntimeProvider runtime={runtime}>
      {children}
    </AssistantRuntimeProvider>
  );
}
