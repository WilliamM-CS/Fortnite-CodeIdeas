# 1v1 Arena Tether System

A Fortnite Creative device that restricts player movement to a configurable radius when activated.

## Features

- **Switch Activation**: Players click a button/switch to activate their tether
- **Configurable Radius**: Default 4 feet, adjustable from 1-10 feet
- **Increase/Decrease Controls**: Players can change tether length with buttons
- **Visual HUD Feedback**: Shows current tether status to players

## Setup Instructions

### In UEFN:

1. **Add Device Classes**: Import `tether_device` from this folder into your UEFN project

2. **Place Required Devices**:
   - Button Device (for activation)
   - Button Device (for increasing radius)
   - Button Device (for decreasing radius)
   - **Button Device (for deactivation) ← NEW!**
   - Movement Modulator Device
   - HUD Message Device

3. **Configure Editable Properties**:
   - Assign the placed devices to the `@editable` properties in `Tether_Device.verse`
   - Set `TetherRadiusFeet` to your desired default (4.0 feet recommended)
   - Adjust `TetherMinRadius` and `TetherMaxRadius` as needed

4. **Connect to Map**:
   - Place the devices in your 1v1 arena
   - Connect button interactions to activate the tether system

### Verse Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| TetherRadiusFeet | float | 4.0 | Default tether radius in feet |
| TetherMinRadius | float | 1.0 | Minimum allowed radius |
| TetherMaxRadius | float | 10.0 | Maximum allowed radius |
| RadiusIncreaseInterval | float | 1.0 | Feet to add/subtract per button press |

## Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `IsPlayerInBounds(InAgent)` | logic | Checks if player is within their tether radius from origin |
| `GetPlayerOrigin(InAgent)` | ?vector3 | Returns the origin position where tether was activated |
| `GetPlayerRadius(InAgent)` | float | Returns the current radius for a player |
| `ResetTether(InAgent)` | void | Deactivates and clears tether for a player |

## How It Works

1. Player clicks the activation button
2. Tether activates with current radius setting (stores origin position)
3. Movement modulator restricts player speed based on radius
4. Players can use +/- buttons to adjust tether size
5. Players can use deactivate button to turn off tether
6. HUD shows current tether status

## New Features (Fixed)

- ✅ **Deactivation Button** — Players can now turn off tether mode
- ✅ **Origin Position Tracking** — `GetPlayerOrigin()` returns where tether was activated
- ✅ **Proper Bounds Checking** — `IsPlayerInBounds()` calculates distance from origin in XY plane
- ✅ **Array Removal Fixed** — Using proper Verse syntax (no `.Remove()` method)

## Future Enhancements

- Visual tether zone display (ring/circle)
- Two-player mutual tether (both must stay apart)
- Timer-based automatic tether reset
- Team-specific tether settings

## Files

- `Tether_Device.verse` - Main device code
- `README.md` - This file

---

*Part of the Fortnite-CodeIdeas repository*
