"""Constants for the AI Agent HA integration."""

DOMAIN = "ai_agent_ha"
CONF_API_KEY = "api_key"
CONF_WEATHER_ENTITY = "weather_entity"

# AI Provider configuration keys
CONF_LLAMA_TOKEN = "llama_token"  # nosec B105
CONF_OPENAI_TOKEN = "openai_token"  # nosec B105
CONF_GEMINI_TOKEN = "gemini_token"  # nosec B105
CONF_OPENROUTER_TOKEN = "openrouter_token"  # nosec B105
CONF_ANTHROPIC_TOKEN = "anthropic_token"  # nosec B105
CONF_LOCAL_URL = "local_url"
CONF_LOCAL_MODEL = "local_model"

# Available AI providers
AI_PROVIDERS = ["anthropic", "openai", "gemini", "openrouter", "llama", "local"]

# AI Provider constants
CONF_MODELS = "models"

# Supported AI providers - Changed default to anthropic (Claude Sonnet 3.7)
DEFAULT_AI_PROVIDER = "anthropic"

# Default models optimized for Claude Sonnet 3.7, GPT-5/o3-mini, and Gemini 2.5
DEFAULT_MODELS = {
    "anthropic": "claude-3-7-sonnet-latest",  # Primary recommendation
    "openai": "gpt-4o-mini",  # Compatible with gpt-5, o3-mini
    "gemini": "gemini-2.0-flash-exp",  # Experimental Gemini 2.0
    "openrouter": "anthropic/claude-3.7-sonnet",  # Claude via OpenRouter
    "llama": "Llama-4-Maverick-17B-128E-Instruct-FP8",
    "local": "llama3.2",
}
