"""LLM provider factory."""

from langchain_core.language_models.chat_models import BaseChatModel

from ..settings import AgentSettings


def get_chat_model(agent_settings: AgentSettings) -> BaseChatModel:
    """Create a chat model based on the configured provider.

    Args:
        agent_settings: Agent configuration settings.

    Returns:
        A configured chat model instance.

    Raises:
        ValueError: If the provider is not supported.
    """
    match agent_settings.LLM_PROVIDER:
        case "google":
            from langchain_google_genai import ChatGoogleGenerativeAI

            return ChatGoogleGenerativeAI(
                model=agent_settings.LLM_MODEL,
                api_key=agent_settings.LLM_API_KEY,
            )
        case "openai":
            from langchain_openai import ChatOpenAI

            return ChatOpenAI(
                model=agent_settings.LLM_MODEL,
                api_key=agent_settings.LLM_API_KEY,
            )
        case "anthropic":
            from langchain_anthropic import ChatAnthropic

            return ChatAnthropic(
                model=agent_settings.LLM_MODEL,
                api_key=agent_settings.LLM_API_KEY,
            )
        case "llamastack":
            from langchain_openai import ChatOpenAI

            return ChatOpenAI(
                model=agent_settings.LLM_MODEL,
                api_key=agent_settings.LLM_API_KEY,
                base_url=agent_settings.LLAMASTACK_URL,
            )
        case _:
            raise ValueError(
                f"Unsupported LLM provider: {agent_settings.LLM_PROVIDER}. "
                "Supported providers: google, openai, anthropic, llamastack"
            )
