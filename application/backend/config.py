import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    """Base application configuration."""
    APP_NAME = os.getenv("APP_NAME", "PulseOps")
    VERSION = os.getenv("APP_VERSION", "1.0.0")
    ENVIRONMENT = os.getenv("ENVIRONMENT", "development")
    PORT = int(os.getenv("APP_PORT", 8000))
    HOST = os.getenv("APP_HOST", "0.0.0.0")
    DEBUG = os.getenv("DEBUG", "false").lower() in ("true", "1", "yes")
    TESTING = False
    SECRET_KEY = os.getenv("SECRET_KEY", "pulseops-dev-secret-key-change-in-prod")
    LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
    SERVICE_NAME = "pulseops-core-engine"

class TestConfig(Config):
    """Configuration for testing."""
    TESTING = True
    DEBUG = True
    ENVIRONMENT = "testing"

class ProductionConfig(Config):
    """Production configuration."""
    DEBUG = False
    ENVIRONMENT = "production"

config_by_name = {
    "development": Config,
    "testing": TestConfig,
    "production": ProductionConfig,
    "default": Config
}
