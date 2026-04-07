using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game/Modules/Playable }

# Tether Device - 1v1 Arena Tether System
# When players click a switch/button, creates a configurable movement restriction zone around each player
# Players can only move within their tether radius, and can change the tether length

tether_device := class(creative_device):

    # ===== Editable Properties =====
    @editable
    ActivateButton : button_device = button_device{}

    @editable
    TetherRadiusFeet : float = 4.0

    @editable
    TetherMinRadius : float = 1.0

    @editable
    TetherMaxRadius : float = 10.0

    @editable
    RadiusIncreaseInterval : float = 1.0

    @editable
    IncreaseButton : button_device = button_device{}

    @editable
    DecreaseButton : button_device = button_device{}

    @editable
    MovementModulator : movement_modulator_device = movement_modulator_device{}

    @editable
    HUDMessage : hud_message_device = hud_message_device{}

    # ===== Internal Variables =====
    var ActivePlayerSet : []agent = array{}
    var PlayerRadii : [agent]float = map{}
    var CurrentRadius : float = 4.0

    # ===== Initialization =====
    OnBegin() <suspends> =
        # Subscribe to button events
        ActivateButton.InteractedEvent.Subscribe(OnTetherActivate)
        IncreaseButton.InteractedEvent.Subscribe(OnIncreaseRadius)
        DecreaseButton.InteractedEvent.Subscribe(OnDecreaseRadius)

        # Initialize movement modulator settings
        MovementModulator.SetSpeedMultiplier(1.0)

        Print("Tether Device Initialized")

    # ===== Event Handlers =====

    OnTetherActivate(Agent : agent) : void =
        if (CurrentRadius >= TetherMinRadius):
            # Player entering tether mode
            if (Agent not in ActivePlayerSet):
                set ActivePlayerSet = ActivePlayerSet + array{Agent}
            
            # Set player's individual radius
            set PlayerRadii = PlayerRadii->[Agent] = CurrentRadius
            
            # Apply movement restriction
            ApplyTetherRestriction(Agent, CurrentRadius)
            
            # Show HUD message
            ShowTetherStatus(Agent, CurrentRadius, true)

    OnIncreaseRadius(Agent : agent) : void =
        NewRadius := CurrentRadius + RadiusIncreaseInterval
        
        if (NewRadius <= TetherMaxRadius):
            set CurrentRadius = NewRadius
            
            # Update all active players' radii
            for (PlayerAgent : ActivePlayerSet):
                set PlayerRadii = PlayerRadii->[PlayerAgent] = CurrentRadius
                ApplyTetherRestriction(PlayerAgent, CurrentRadius)
            
            ShowTetherStatus(Agent, CurrentRadius, true)
            Print("Tether radius increased to: {CurrentRadius} feet")

    OnDecreaseRadius(Agent : agent) : void =
        NewRadius := CurrentRadius - RadiusIncreaseInterval
        
        if (NewRadius >= TetherMinRadius):
            set CurrentRadius = NewRadius
            
            # Update all active players' radii
            for (PlayerAgent : ActivePlayerSet):
                set PlayerRadii = PlayerRadii->[PlayerAgent] = CurrentRadius
                ApplyTetherRestriction(PlayerAgent, CurrentRadius)
            
            ShowTetherStatus(Agent, CurrentRadius, true)
            Print("Tether radius decreased to: {CurrentRadius} feet")

    # ===== Core Functions =====

    ApplyTetherRestriction(InAgent : agent, RadiusFeet : float) : void =
        # Calculate movement restriction based on radius
        # 1 foot = ~0.3 unreal units, so 4 feet ≈ 1.2 units
        SpeedMultiplier := RadiusFeet / 4.0
        
        # Apply speed modulation (players move slower in smaller tethers)
        if (SpeedMultiplier < 1.0):
            MovementModulator.ModifySpeed(InAgent, SpeedMultiplier)
        else:
            # Full speed allowed at max radius
            MovementModulator.ModifySpeed(InAgent, 1.0)

    ShowTetherStatus(InAgent : agent, Radius : float, Enabled : logic) : void =
        if (Enabled):
            HUDMessage.Show(InAgent, "TETHER ACTIVE: {Radius}ft radius")
        else:
            HUDMessage.Show(InAgent, "TETHER DEACTIVATED")

    # ===== Utility Functions =====

    # Get player's current tether status
    GetPlayerRadius(InAgent : agent)<transacts> : float =
        if (RadiusOpt := PlayerRadii[InAgent]):
            return RadiusOpt
        else:
            return TetherRadiusFeet

    # Check if player is within their tether bounds
    IsPlayerInBounds(InAgent : agent, CurrentPos : vector3, OriginPos : vector3)<transacts> : logic =
        if (RadiusOpt := PlayerRadii[InAgent]):
            Distance := |CurrentPos - OriginPos|
            TetherUnits := RadiusOpt * 0.3048  # Convert feet to units
            return Distance <= TetherUnits
        return true

    # Reset tether for a player
    ResetTether(InAgent : agent) : void =
        if (InAgent in ActivePlayerSet):
            set ActivePlayerSet = ActivePlayerSet.Remove(InAgent)
            set PlayerRadii = PlayerRadii->[InAgent] = TetherRadiusFeet
            MovementModulator.ModifySpeed(InAgent, 1.0)
