using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

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
        # Toggle through values: 0.5 -> 0.75 -> 1.0 -> 1.25 -> 1.5 -> 1.75 -> 2.0 -> 0.5
        if (CurrentJumpHeight >= 2.0):
            set CurrentJumpHeight = MinJumpHeight
        else:
            set CurrentJumpHeight = CurrentJumpHeight + JumpHeightIncrement

        # Apply the jump height modification
        ApplyJumpHeightToAgent(Agent)
        UpdateHUD(Agent)

    OnSpeedPressed(Agent: agent): void =
        # Toggle through values: 0.5 -> 0.75 -> 1.0 -> 1.25 -> 1.5 -> 1.75 -> 2.0 -> 0.5
        if (CurrentSpeed >= 2.0):
            set CurrentSpeed = MinSpeed
        else:
            set CurrentSpeed = CurrentSpeed + SpeedIncrement

        # Apply the speed modification
        ApplySpeedToAgent(Agent)
        UpdateHUD(Agent)

    OnHealthPressed(Agent: agent): void =
        # Cycle: 100 -> 110 -> 120 -> 130 -> 140 -> 150 -> 160 -> 170 -> 180 -> 190 -> 200 -> 50 -> 100
        if (CurrentHealth >= MaxHealth):
            set CurrentHealth = MinHealth
        else:
            set CurrentHealth = CurrentHealth + HealthIncrement

        # Apply the health modification
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
            # Format jump height as percentage
            JumpPercent := CurrentJumpHeight * 100
            JumpStr := "Jump: {JumpPercent:F0}%"

            # Format speed as percentage
            SpeedPercent := CurrentSpeed * 100
            SpeedStr := "Speed: {SpeedPercent:F0}%"

            # Format health
            HealthStr := "Health: {CurrentHealth}"

            # Build full HUD message
            FullMessage := "{JumpStr} | {SpeedStr} | {HealthStr}"

            # Send to HUD channel for display to player
            if (PlayerCharacter := Agent.GetFortCharacter[]):
                PlayerCharacter.SendMessageToClient(HUDChannel, FullMessage)

    # ========================================
    # APPLY FUNCTIONS
    # ========================================

    ApplyJumpHeightToAgent(Agent: agent): void =
        # Create a fort_jump_height_modification effect
        JumpMod := modifier{
            JumpsMaxHeight := CurrentJumpHeight
        }

        # Apply to the agent
        if (FortCharacter := Agent.GetFortCharacter[]):
            FortCharacter.AddMutator(JumpMod)

    ApplySpeedToAgent(Agent: agent): void =
        # Create a speed modification
        SpeedMod := modifier{
            MovementSpeedMultiplier := CurrentSpeed
        }

        # Apply to the agent
        if (FortCharacter := Agent.GetFortCharacter[]):
            FortCharacter.AddMutator(SpeedMod)

    ApplyHealthToAgent(Agent: agent): void =
        # Set the agent's health directly
        if (FortCharacter := Agent.GetFortCharacter[]):
            if (HealthComponent := FortCharacter.GetHealthComponent[]):
                HealthComponent.SetHealth(CurrentHealth)