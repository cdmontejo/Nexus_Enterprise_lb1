from typing import Literal, Optional, Tuple, Any, Dict
from pydantic import BaseModel, Field, field_validator
import re

HEX_COLOR_REGEX = re.compile(r"^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$")


class ConfigSchema(BaseModel):
    
    username: str = Field(
        default="Administrador NEXUS",
        min_length=1,
        max_length=60,
        description="User display name, fully supports UTF-8 characters."
    )
    theme: Literal["dark", "light"] = Field(
        default="dark",
        description="Visual theme: dark or light."
    )
    accent_color: str = Field(
        default="#1FA8FF",
        description="Hexadecimal accent color code (e.g. #1FA8FF)."
    )
    font_size: int = Field(
        default=14,
        ge=10,
        le=28,
        description="Base UI font size between 10 and 28 points."
    )
    language: Literal["es", "en"] = Field(
        default="es",
        description="Interface language: es (Spanish) or en (English)."
    )
    profile_picture: str = Field(
        default="data/profile/profile.png",
        description="Path to local profile picture."
    )
    auto_save: bool = Field(
        default=False,
        description="Flag indicating if modifications auto-commit."
    )
    diagnostic_mode: bool = Field(
        default=True,
        description="Enables telemetry and real-time live diagnostics."
    )

    @field_validator("accent_color")
    @classmethod
    def validate_hex_color(cls, v: str) -> str:
        if not HEX_COLOR_REGEX.match(v):
            raise ValueError(f"Color '{v}' no es un formato hexadecimal válido (ejemplo: #1FA8FF o #333).")
        return v.upper()

    @field_validator("username")
    @classmethod
    def validate_username(cls, v: str) -> str:
        stripped = v.strip()
        if not stripped:
            raise ValueError("El nombre de usuario no puede estar vacío.")
        return stripped


def validate_config_data(data: Dict[str, Any]) -> Tuple[bool, Optional[ConfigSchema], Optional[str]]:
    try:
        model = ConfigSchema(**data)
        return True, model, None
    except Exception as exc:
        return False, None, str(exc)
