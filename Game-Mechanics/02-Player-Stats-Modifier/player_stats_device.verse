using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Mutator classes defined at module scope
jump_height_modifier := class(creative_mutator):
    MaxJumpHeight: float = 1.0

speed_modifier := class(creative_mutator):
    MovementSpeedMultiplier: float = 1.0

player_stats_device := class(creative_device):

    # ========================================
    # EDITABLE PROPERTIES - Set in UEFN Editor
    # ========================================

    @editable
    JumpHeightButton: button_device = button_device{}

    @editable
    SpeedButton: button_device = button_device{}

    @editable
    HealthButton: button_device = button_device{}

    @editable
    ResetButton: button_device = button_device{}

    # Default values
    @editable
    var DefaultJumpHeight: float = 1.0

    @editable
    var DefaultSpeed: float = 1.0

    @editable
    var DefaultHealth: int = 100

    # Value increments
    @editable
    var JumpHeightIncrement: float = 0.1

    @editable
    var SpeedIncrement: float = 0.1

    @editable
    var HealthIncrement: int = 10

    # Min/Max bounds
    @editable
    var MinJumpHeight: float = 0.5

    @editable
    var MaxJumpHeight: float = 2.0

    @editable
    var MinSpeed: float = 0.5

    @editable
    var MaxSpeed: float = 2.0

    @editable
    var MinHealth: int = 50

    @editable
    var MaxHealth: int = 200

    # ========================================
    # HUD CONFIGURATION
    # ========================================

    @editable
    var HUDEnabled: logic = true

    @editable
    var HUDChannel: int = 1

    # ========================================
    # INTERNAL STATE
    # ========================================

    var CurrentJumpHeight: float = 1.0
    var CurrentSpeed: float = 1.0
    var CurrentHealth: int = 100

    # ========================================
    # DEVICE INITIALIZATION
    # ========================================

    OnBegin<override>()<suspends> =
        # Initialize defaults
        set CurrentJumpHeight = DefaultJumpHeight
        set CurrentSpeed = DefaultSpeed
        set CurrentHealth = DefaultHealth

        # Subscribe to button events
        JumpHeightButton.InteractedEvent.Subscribe(OnJumpHeightPressed)
        SpeedButton.InteractedEvent.Subscribe(OnSpeedPressed)
        HealthButton.InteractedEvent.Subscribe(OnHealthPressed)
        ResetButton.InteractedEvent.Subscribe(OnResetPressed)

    # ========================================
    # BUTTON HANDLERS
    # ========================================

    OnJumpHeightPressed(Agent: agent): void =
        # Cycle through values
        if (CurrentJumpHeight >= 2.0):
            set CurrentJumpHeight = MinJumpHeight
        else:
            set CurrentJumpHeight = CurrentJumpHeight + JumpHeightIncrement

        ApplyJumpHeightToAgent(Agent)
        UpdateHUD(Agent)

    OnSpeedPressed(Agent: agent): void =
        # Cycle through values
        if (CurrentSpeed >= 2.0):
            set CurrentSpeed = MinSpeed
        else:
            set CurrentSpeed = CurrentSpeed + SpeedIncrement

        ApplySpeedToAgent(Agent)
        UpdateHUD(Agent)

    OnHealthPressed(Agent: agent): void =
        # Cycle through values
        if (CurrentHealth >= MaxHealth):
            set CurrentHealth = MinHealth
        else:
            set CurrentHealth = CurrentHealth + HealthIncrement

        ApplyHealthToAgent(Agent)
        UpdateHUD(Agent)

    OnResetPressed(Agent: agent): void =
        # Reset all stats to defaults
        set CurrentJumpHeight = DefaultJumpHeight
        set CurrentSpeed = DefaultSpeed
        set CurrentHealth = DefaultHealth

        ApplyJumpHeightToAgent(Agent)
        ApplySpeedToAgent(Agent)
        ApplyHealthToAgent(Agent)
        UpdateHUD(Agent)

    # ========================================
    # HUD FEEDBACK
    # ========================================

    UpdateHUD(Agent: agent): void =
        if (HUDEnabled?):
            JumpPercent := CurrentJumpHeight * 100
            SpeedPercent := CurrentSpeed * 100

            JumpStr := "Jump: {JumpPercent:F0}%"
            SpeedStr := "Speed: {SpeedPercent:F0}%"
            HealthStr := "Health: {CurrentHealth}"

            FullMessage := "{JumpStr} | {SpeedStr} | {HealthStr}"

            if (PlayerCharacter := Agent.GetFortCharacter[]):
                PlayerCharacter.SendMessageToClient(HUDChannel, FullMessage)

    # ========================================
    # APPLY FUNCTIONS
    # ========================================

    ApplyJumpHeightToAgent(Agent: agent): void =
        if (FortChar := Agent.GetFortCharacter[]):
            JumpMutator := jump_height_modifier{
                MaxJumpHeight := CurrentJumpHeight
            }
            FortChar.AddMutator(JumpMutator)

    ApplySpeedToAgent(Agent: agent): void =
        if (FortChar := Agent.GetFortCharacter[]):
            SpeedMutator := speed_modifier{
                MovementSpeedMultiplier := CurrentSpeed
            }
            FortChar.AddMutator(SpeedMutator)

    ApplyHealthToAgent(Agent: agent): void =
        if (FortChar := Agent.GetFortCharacter[]):
            if (HealthComponent := FortChar.GetHealthComponent[]):
                HealthComponent.SetMaxHealth(CurrentHealth)
                HealthComponent.SetHealth(CurrentHealth)