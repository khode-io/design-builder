---
title: Token Format
description: Learn the W3C Design Tokens format and how to structure your token files.
---

Design Builder uses the W3C Design Tokens format for maximum compatibility with design tools and other platforms.

## File Structure

A token file must include a `$schemaVersion` field and theme mode objects:

```json
{
  "$schemaVersion": "3.0",
  "light": {
    "$variables": {},
    "color": {},
    "typography": {},
    "dimension": {}
  },
  "dark": {
    "$variables": {},
    "color": {},
    "typography": {},
    "dimension": {}
  }
}
```

## Theme Modes

Each top-level key (except `$schemaVersion`) represents a theme mode:

- `light` - Light mode tokens
- `dark` - Dark mode tokens
- `high-contrast` - Accessibility mode tokens
- Custom modes can be added as needed

## Variables Section

The `$variables` section defines reusable values:

```json
{
  "light": {
    "$variables": {
      "color": {
        "brand": {
          "primary": "#1A1A2E",
          "secondary": "#2D3A8C"
        },
        "semantic": {
          "success": "#10B981",
          "error": "#EF4444"
        }
      },
      "spacing": {
        "xs": "4px",
        "sm": "8px",
        "md": "16px",
        "lg": "24px",
        "xl": "32px"
      }
    }
  }
}
```

## Color Tokens

Color tokens use the `$type: "color"` property:

```json
{
  "color": {
    "brand": {
      "primary": { "$type": "color", "$value": "$color.brand.primary" },
      "secondary": { "$type": "color", "$value": "$color.brand.secondary" }
    },
    "semantic": {
      "success": { "$type": "color", "$value": "$color.semantic.success" },
      "error": { "$type": "color", "$value": "$color.semantic.error" }
    }
  }
}
```

### Color Token Groups

Design Builder supports organized color groups for different UI elements:

```json
{
  "$variables": {
    "color": {
      "brand": { "primary": "#1A1A2E", "secondary": "#2D3A8C" },
      "semantic": { "success": "#10B981", "error": "#EF4444", "warning": "#F59E0B", "info": "#3B82F6" },
      "neutral": { "white": "#FFFFFF", "gray100": "#F3F4F6", "gray900": "#111827" }
    }
  },
  "color": {
    "action": {
      "filledPrimary": { "$type": "color", "$value": "$color.brand.primary" },
      "filledHover": { "$type": "color", "$value": "$color.brand.secondary" },
      "ghostPrimary": { "$type": "color", "$value": "$color.semantic.info" },
      "outline": { "$type": "color", "$value": "$color.brand.primary" }
    },
    "background": {
      "default": { "$type": "color", "$value": "$color.neutral.white" },
      "card": { "$type": "color", "$value": "$color.neutral.gray100" }
    },
    "foreground": {
      "default": { "$type": "color", "$value": "$color.neutral.gray900" },
      "inverse": { "$type": "color", "$value": "$color.neutral.white" }
    },
    "input": {
      "fill": { "$type": "color", "$value": "$color.neutral.white" },
      "outline": { "$type": "color", "$value": "$color.neutral.gray100" },
      "focus": { "$type": "color", "$value": "$color.semantic.info" }
    },
    "stroke": {
      "primary": { "$type": "color", "$value": "$color.neutral.gray100" },
      "emphasis": { "$type": "color", "$value": "$color.neutral.gray900" },
      "divider": { "$type": "color", "$value": "$color.neutral.gray100" },
      "error": { "$type": "color", "$value": "$color.semantic.error" }
    },
    "feedback": {
      "success": { "$type": "color", "$value": "$color.semantic.success" },
      "error": { "$type": "color", "$value": "$color.semantic.error" },
      "warning": { "$type": "color", "$value": "$color.semantic.warning" }
    }
  }
}
```

**Available color groups:**
- `action` - Button, chip, toggle colors
- `background` - Page/section backgrounds
- `canvas` - Container backgrounds
- `feedback` - Success, error, warning states
- `foreground` - Text colors
- `icon` - Icon/glyph colors
- `indicator` - Badge, chip, tag colors
- `input` - Form control colors
- `stroke` - **Border, divider, outline colors**
- `surface` - Elevated container colors

## Typography Tokens

Typography tokens define text styles:

```json
{
  "typography": {
    "heading": {
      "large": {
        "$type": "typography",
        "$value": {
          "fontSize": "32px",
          "fontWeight": "700",
          "fontFamily": "Inter",
          "letterSpacing": "-0.5px",
          "height": "40px"
        }
      },
      "medium": {
        "$type": "typography",
        "$value": {
          "fontSize": "24px",
          "fontWeight": "600",
          "fontFamily": "Inter"
        }
      }
    },
    "body": {
      "large": {
        "$type": "typography",
        "$value": {
          "fontSize": "16px",
          "fontWeight": "400",
          "fontFamily": "Inter",
          "height": "24px"
        }
      }
    }
  }
}
```

### Typography Properties

| Property | Type | Description |
|----------|------|-------------|
| `fontSize` | string | Font size with unit (px) |
| `fontWeight` | string/number | Font weight (400, 600, 700, etc.) |
| `fontFamily` | string | Font family name |
| `letterSpacing` | string | Letter spacing with unit |
| `height` | string | Line height with unit |

## Dimension Tokens

Dimension tokens define spacing, sizes, and radii:

```json
{
  "dimension": {
    "spacing": {
      "xs": { "$type": "dimension", "$value": "$spacing.xs" },
      "sm": { "$type": "dimension", "$value": "$spacing.sm" },
      "md": { "$type": "dimension", "$value": "$spacing.md" },
      "lg": { "$type": "dimension", "$value": "$spacing.lg" },
      "xl": { "$type": "dimension", "$value": "$spacing.xl" }
    },
    "radius": {
      "sm": { "$type": "dimension", "$value": "4px" },
      "md": { "$type": "dimension", "$value": "8px" },
      "lg": { "$type": "dimension", "$value": "16px" },
      "xl": { "$type": "dimension", "$value": "24px" }
    }
  }
}
```

### Size Token Groups

Beyond spacing and radius, you can define other size categories:

```json
{
  "$variables": {
    "sizes": {
      "blur": { "sm": "4px", "md": "8px", "lg": "16px" },
      "font": { "sm": "12px", "md": "16px", "lg": "20px", "xl": "24px" },
      "icon": { "sm": "16px", "md": "24px", "lg": "32px" },
      "motion": { "fast": "150ms", "normal": "300ms", "slow": "500ms" },
      "padding": { "sm": "8px", "md": "16px", "lg": "24px" },
      "border": { "thin": "1px", "thick": "2px" }
    }
  },
  "dimension": {
    "blur": {
      "modal": { "$type": "dimension", "$value": "$sizes.blur.md" }
    },
    "font": {
      "body": { "$type": "dimension", "$value": "$sizes.font.md" }
    },
    "icon": {
      "default": { "$type": "dimension", "$value": "$sizes.icon.md" }
    },
    "motion": {
      "transition": { "$type": "dimension", "$value": "$sizes.motion.normal" }
    },
    "padding": {
      "button": { "$type": "dimension", "$value": "$sizes.padding.md" }
    },
    "border": {
      "thin": { "$type": "dimension", "$value": "$sizes.border.thin" },
      "thick": { "$type": "dimension", "$value": "$sizes.border.thick" }
    }
  }
}
```

## Complete Example

Here's a complete token file with all token types:

```json
{
  "$schemaVersion": "3.0",
  "light": {
    "$variables": {
      "color": {
        "brand": {
          "primary": "#1A1A2E",
          "secondary": "#2D3A8C"
        }
      },
      "spacing": {
        "unit": "8px"
      }
    },
    "color": {
      "brand": {
        "primary": {
          "$type": "color",
          "$value": "$color.brand.primary"
        }
      }
    },
    "typography": {
      "heading": {
        "large": {
          "$type": "typography",
          "$value": {
            "fontSize": "32px",
            "fontWeight": "700"
          }
        }
      }
    },
    "dimension": {
      "spacing": {
        "md": {
          "$type": "dimension",
          "$value": "$spacing.unit"
        }
      }
    }
  },
  "dark": {
    "$variables": {
      "color": {
        "brand": {
          "primary": "#4A5568"
        }
      }
    }
  }
}
```

## Variable References

Reference variables using the `$variable.path` syntax:

```json
{
  "$value": "$color.brand.primary"
}
```

Nested references are supported:

```json
{
  "$variables": {
    "color": {
      "base": {
        "blue": "#3B82F6"
      },
      "semantic": {
        "info": "$color.base.blue"
      }
    }
  },
  "color": {
    "button": {
      "primary": {
        "$type": "color",
        "$value": "$color.semantic.info"
      }
    }
  }
}
```
