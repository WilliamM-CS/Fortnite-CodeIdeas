# Player Stats Modifier

A Fortnite Creative device that allows players to dynamically adjust their jump height, movement speed, and health through button interactions.

## Features

- **Jump Height Control** - Cycle through custom jump heights (0.5x to 2.0x)
- **Speed Control** - Cycle through movement speed modifiers (0.5x to 2.0x)
- **Health Control** - Cycle through health values (50 to 200)
- **Reset Function** - Instantly reset all stats to default values
- **Visual HUD Feedback** - Shows current stats on screen after each change

## Setup Instructions

### In UEFN:

1. **Add Device Class**: Import `player_stats_device` from this folder into your UEFN project

2. **Place Required Devices**:
   - Button Device (for jump height)
   - Button Device (for speed)
   - Button Device (for health)
   - Button Device (for resetting)
   - (Optional) HUD Message Device for advanced feedback

3. **Configure Editable Properties**:
   - Assign buttons to the `@editable` properties in `player_stats_device.verse`
   - Set default values for starting stats
   - Adjust min/max bounds as needed
   - Configure increment sizes for each stat
   - Set `HUDEnabled` to true for on-screen feedback

4. **Connect to Map**:
   - Place buttons in your map
   - Connect button interactions to the device
   - Assign the device to players via spawner or game manager

### Verse Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| JumpHeightButton | button_device | - | Button to cycle jump height |
| SpeedButton | button_device | - | Button to cycle speed |
| HealthButton | button_device | - | Button to cycle health |
| ResetButton | button_device | - | Button to reset all stats |
| DefaultJumpHeight | float | 1.0 | Starting jump height multiplier |
| DefaultSpeed | float | 1.0 | Starting speed multiplier |
| DefaultHealth | int | 100 | Starting health value |
| JumpHeightIncrement | float | 0.1 | Jump height change per button press |
| SpeedIncrement | float | 0.1 | Speed change per button press |
| HealthIncrement | int | 10 | Health change per button press |
| MinJumpHeight | float | 0.5 | Minimum jump height |
| MaxJumpHeight | float | 2.0 | Maximum jump height |
| MinSpeed | float | 0.5 | Minimum speed |
| MaxSpeed | float | 2.0 | Maximum speed |
| MinHealth | int | 50 | Minimum health |
| MaxHealth | int | 200 | Maximum health |
| HUDEnabled | logic | true | Enable/disable HUD messages |
| HUDChannel | int | 1 | HUD message channel number |

## How It Works

1. Player presses the **Jump Button** → cycles jump height by increment
2. Player presses the **Speed Button** → cycles speed by increment
3. Player presses the **Health Button** → cycles health by increment
4. Player presses the **Reset Button** → restores all stats to defaults

**HUD Feedback:** After any change, a message appears showing all current stats:
```
Jump: 120% | Speed: 150% | Health: 100
```

Values **cycle** (wrap around):
- Jump/Speed: `0.5 → 0.6 → ... → 2.0 → 0.5`
- Health: `50 → 60 → ... → 200 → 50`

## Files

- `player_stats_device.verse` - Main device code
- `README.md` - This file

---

*Part of the Fortnite-CodeIdeas repository*