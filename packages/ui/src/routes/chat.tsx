import { createFileRoute } from '@tanstack/react-router';
import { ChatPage } from '@dagshub-ai-dev-plaform-support/chat';
import { Thread } from '@/components/assistant-ui/thread';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const Route = createFileRoute('/chat' as any)({
  component: Chat,
});

function Chat() {
  return (
    <div className="absolute inset-0">
      <ChatPage>
        <Thread />
      </ChatPage>
    </div>
  );
}