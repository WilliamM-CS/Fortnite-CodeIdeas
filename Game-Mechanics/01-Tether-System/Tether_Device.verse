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
    DeactivateButton : button_device = button_device{}

    @editable
    MovementModulator : movement_modulator_device = movement_modulator_device{}

    @editable
    HUDMessage : hud_message_device = hud_message_device{}

    # ===== Internal Variables =====
    var ActivePlayerSet : []agent = array{}
    var PlayerRadii : [agent]float = map{}
    var OriginPositions : [agent]vector3 = map{}
    var CurrentRadius : float = 4.0

    # ===== Initialization =====
    OnBegin() <suspends> =
        # Subscribe to button events
        ActivateButton.InteractedEvent.Subscribe(OnTetherActivate)
        IncreaseButton.InteractedEvent.Subscribe(OnIncreaseRadius)
        DecreaseButton.InteractedEvent.Subscribe(OnDecreaseRadius)
        DeactivateButton.InteractedEvent.Subscribe(OnTetherDeactivate)

        # Initialize movement modulator settings
        MovementModulator.SetSpeedMultiplier(1.0)

        Print("Tether Device Initialized")

    # ===== Event Handlers =====

    OnTetherActivate(Agent : agent) : void =
        if (CurrentRadius >= TetherMinRadius):
            # Player entering tether mode
            if (not (Agent in ActivePlayerSet)):
                set ActivePlayerSet = ActivePlayerSet + array{Agent}
                
                # Store origin position where player activated tether
                if (FortniteCharacter := Agent.GetFortniteCharacter[]):
                    set OriginPositions = OriginPositions->[Agent] = FortniteCharacter.GetTransform().Translation
            
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

    OnTetherDeactivate(Agent : agent) : void =
        # Remove player from active set
        if (Agent in ActivePlayerSet):
            # Filter out the agent from the array (correct Verse syntax)
            NewSet : []agent = array{}
            for (A : ActivePlayerSet):
                if (A <> Agent):
                    set NewSet = NewSet + array{A}
            set ActivePlayerSet = NewSet
            
            # Remove from maps
            set PlayerRadii = RemoveFromMap(PlayerRadii, Agent)
            set OriginPositions = RemoveFromMap(OriginPositions, Agent)
            
            # Restore full speed
            MovementModulator.ModifySpeed(Agent, 1.0)
            ShowTetherStatus(Agent, 0.0, false)
            Print("Tether deactivated for player")

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

    # Helper function to remove from agent-keyed map
    RemoveFromMap<K, V>(Map : [agent]V, Key : agent)<transacts> : [agent]V =
        NewMap : [agent]V = map{}
        for (K->V : Map):
            if (K <> Key):
                set NewMap = NewMap->[K] = V
        return NewMap

    # Get player's current tether status
    GetPlayerRadius(InAgent : agent)<transacts> : float =
        if (RadiusOpt := PlayerRadii[InAgent]):
            return RadiusOpt
        else:
            return TetherRadiusFeet

    # Check if player is within their tether bounds
    IsPlayerInBounds(InAgent : agent)<transacts> : logic =
        if (RadiusOpt := PlayerRadii[InAgent]):
            if (OriginOpt := OriginPositions[InAgent]):
                if (FortniteCharacter := InAgent.GetFortniteCharacter[]):
                    CurrentPos := FortniteCharacter.GetTransform().Translation
                    Distance := DistanceXY(CurrentPos, OriginOpt)
                    TetherUnits := RadiusOpt * 0.3048  # Convert feet to meters (Unreal units)
                    return Distance <= TetherUnits
        return true

    # Calculate distance in XY plane (ignoring height)
    DistanceXY(A : vector3, B : vector3) : float =
        DX := A.X - B.X
        DY := A.Y - B.Y
        return Sqrt(DX * DX + DY * DY)

    # Get player's origin position
    GetPlayerOrigin(InAgent : agent)<transacts> : ?vector3 =
        return OriginPositions[InAgent]

    # Reset tether for a player
    ResetTether(InAgent : agent) : void =
        if (InAgent in ActivePlayerSet):
            # Filter out the agent from the array
            NewSet : []agent = array{}
            for (A : ActivePlayerSet):
                if (A <> InAgent):
                    set NewSet = NewSet + array{A}
            set ActivePlayerSet = NewSet
            
            set PlayerRadii = RemoveFromMap(PlayerRadii, InAgent)
            set OriginPositions = RemoveFromMap(OriginPositions, InAgent)
            MovementModulator.ModifySpeed(InAgent, 1.0)
