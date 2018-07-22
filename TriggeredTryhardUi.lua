TTUI = {}
TTUI.name = "TriggeredTryhardUi"

function TTUI.OnAddOnLoaded(event, addonName)
  if addonName == TTUI.name then
    TTUI:Initialize()
  end
end

function TTUI.OnPlayerLoaded()
  EVENT_MANAGER:UnregisterForEvent(TTUI.name, EVENT_PLAYER_ACTIVATED)

  CHAT_SYSTEM:AddMessage("TriggeredTryhardUi by @kArvee")
end

function TTUI.OnUpdate()
  UnitFramesInfoRightBlockFPSLabel:SetText(string.format("%d fps & %s ms", GetFramerate(), GetLatency()))
  UnitFramesInfoRightBlockTimeLabel:SetText(string.format("%s", GetTimeString()))
end

function TTUI:Initialize()
  EVENT_MANAGER:UnregisterForEvent(TTUI.name, EVENT_ADD_ON_LOADED)
  TTUI.InitializeControls()
  TTUI.InitUnitPower("player")
  TTUI.HideControls()
  TTUI.AddUiAsFragment()
end

function TTUI:InitializeControls()
  powertype_controls = {}
  powertype_controls.player = {
    ["HEALTH_CURRENT_LABEL"] = UnitFramesPlayerHealthValueLabel,
    ["HEALTH_BAR"] = UnitFramesPlayerHealthBar,
    ["MAGICKA_CURRENT_LABEL"] = UnitFramesPlayerMagickaValueLabel,
    ["MAGICKA_BAR"] = UnitFramesPlayerMagickaBar,
    ["STAMINA_CURRENT_LABEL"] = UnitFramesPlayerStaminaValueLabel,
    ["STAMINA_BAR"] = UnitFramesPlayerStaminaBar
  }
  powertype_controls.reticleover = {
    ["HEALTH_CURRENT_LABEL"] = UnitFramesTargetHealthValueLabel,
    ["HEALTH_BAR"] = UnitFramesTargetHealthBar
  }
end

function TTUI.OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
  if unitTag == "player" then
    powerControl = powertype_controls.player
    if powerType == POWERTYPE_MAGICKA then
      powerControl["MAGICKA_BAR"]:SetMinMax(0, powerEffectiveMax)
      powerControl["MAGICKA_BAR"]:SetValue(powerValue)
      TTUI.SetPowerStatusValue(unitTag, "MAGICKA", powerValue, powerEffectiveMax)
    end
    if powerType == POWERTYPE_STAMINA then
      powerControl["STAMINA_BAR"]:SetMinMax(0, powerEffectiveMax)
      powerControl["STAMINA_BAR"]:SetValue(powerValue)
      TTUI.SetPowerStatusValue(unitTag, "STAMINA", powerValue, powerEffectiveMax)
    end
  end
  if unitTag == "reticleover" then
    powerControl = powertype_controls.reticleover
  end
  if powerType == POWERTYPE_HEALTH then
    powerControl["HEALTH_BAR"]:SetMinMax(0, powerEffectiveMax)
    powerControl["HEALTH_BAR"]:SetValue(powerValue)
    TTUI.SetPowerStatusValue(unitTag, "HEALTH", powerValue, powerEffectiveMax)
  end
end

function TTUI.OnVisualAdded(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
  if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
    if unitTag == "player" then
      local shieldColor = ZO_ColorDef:New("8f8f8f")
      UnitFramesPlayerHealthBar:SetColor(shieldColor:UnpackRGBA())
      UnitFramesPlayerHealthShieldValueLabel:SetText(string.format("(%6d)", value))
    end
  end
end

function TTUI.OnVisualUpdated(
  eventCode,
  unitTag,
  unitAttributeVisual,
  statType,
  attributeType,
  powerType,
  value,
  maxValue)
  if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
    if unitTag == "player" then
      UnitFramesPlayerHealthShieldValueLabel:SetText(string.format("(%6d)", value))
    end
  end
end

function TTUI.OnVisualRemoved(
  eventCode,
  unitTag,
  unitAttributeVisual,
  statType,
  attributeType,
  powerType,
  value,
  maxValue)
  if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
    if unitTag == "player" then
      local backToHealthColor = ZO_ColorDef:New("a25d7c")
      UnitFramesPlayerHealthBar:SetColor(backToHealthColor:UnpackRGBA())
      UnitFramesPlayerHealthShieldValueLabel:SetText("")
    end
  end
end

function TTUI.OnTargetChanged(eventCode)
  if DoesUnitExist("reticleover") then
    UnitFramesTarget:SetHidden(false)
    TTUI.InitUnitPower("reticleover")
  else
    if IsUnitDead("reticleover") then
    end
    UnitFramesTarget:SetHidden(true)
  end
end

function TTUI.OnDeathStateChanged(eventCode, unitTag, isDead)
end

function TTUI.InitUnitPower(unitTag)
  local currentHealth, maxHealth, effectiveMaxHealth = GetUnitPower(unitTag, POWERTYPE_HEALTH)
  local currentMagicka, maxMagicka, effectiveMaxMagicka = GetUnitPower(unitTag, POWERTYPE_MAGICKA)
  local currentStamina, maxStamina, effectiveMaxStamina = GetUnitPower(unitTag, POWERTYPE_STAMINA)
  if unitTag == "player" then
    powerControl = powertype_controls.player

    powerControl["MAGICKA_BAR"]:SetMinMax(0, maxMagicka)
    powerControl["MAGICKA_BAR"]:SetValue(currentMagicka)
    TTUI.SetPowerStatusValue(unitTag, "MAGICKA", currentMagicka, effectiveMaxMagicka)

    powerControl["STAMINA_BAR"]:SetMinMax(0, maxStamina)
    powerControl["STAMINA_BAR"]:SetValue(currentStamina)
    TTUI.SetPowerStatusValue(unitTag, "STAMINA", currentStamina, effectiveMaxStamina)
  end
  if unitTag == "reticleover" then
    powerControl = powertype_controls.reticleover
  end
  powerControl["HEALTH_BAR"]:SetMinMax(0, maxHealth)
  powerControl["HEALTH_BAR"]:SetValue(currentHealth)
  TTUI.SetPowerStatusValue(unitTag, "HEALTH", currentHealth, effectiveMaxHealth)
end

function TTUI.SetPowerStatusValue(unitTag, type, current, effective)
  if unitTag == "player" then
    powerControl = powertype_controls.player
    powerControl[type .. "_CURRENT_LABEL"]:SetText(string.format("%6s / %6s", current, effective))
  end
  if unitTag == "reticleover" then
    if type == "HEALTH" then
      powertype_controls.reticleover["HEALTH_CURRENT_LABEL"]:SetText(string.format("%6s / %6s", current, effective))
    end
  end
end

function TTUI.HideControls()
  TTUI.HideCompass(true)
end

function TTUI.HideCompass(hide)
  -- frame
  lCompassFrame = COMPASS_FRAME.control
  if lCompassFrame then
    for lIndex, lPos in pairs({"Left", "Center", "Right"}) do
      lWidget = lCompassFrame:GetNamedChild(lPos)
      if lWidget then
        lWidget:SetHidden(hide)
      end
    end
  end
  -- pins
  lCompassPins = COMPASS.control
  if lCompassPins then
    lWidget = lCompassPins:GetNamedChild("Container")
    if lWidget then
      lWidget:SetHidden(hide)
    end
  end
  if hide then
    -- above text
    COMPASS.centerOverPinLabel:SetText("")
    COMPASS.centerOverPinLabelAnimation:PlayBackward()
  end
end

function TTUI.AddUiAsFragment()
  local fragment = ZO_FadeSceneFragment:New(UnitFramesPlayer)
  SCENE_MANAGER:GetScene("hud"):AddFragment(fragment)
  SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment)
end

EVENT_MANAGER:RegisterForEvent(TTUI.name, EVENT_ADD_ON_LOADED, TTUI.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(TTUI.name, EVENT_PLAYER_ACTIVATED, TTUI.OnPlayerLoaded)
EVENT_MANAGER:RegisterForEvent(TTUI.name, EVENT_POWER_UPDATE, TTUI.OnPowerUpdate)
EVENT_MANAGER:RegisterForEvent(TTUI.name, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, TTUI.OnVisualAdded)
EVENT_MANAGER:RegisterForEvent(TTUI.name, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, TTUI.OnVisualRemoved)
EVENT_MANAGER:RegisterForEvent(TTUI.name, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, TTUI.OnVisualUpdated)
EVENT_MANAGER:RegisterForEvent(TTUI.name, EVENT_RETICLE_TARGET_CHANGED, TTUI.OnTargetChanged)
EVENT_MANAGER:RegisterForEvent(TTUI.name, EVENT_UNIT_DEATH_STATE_CHANGED, TTUI.OnDeathStateChanged)
EVENT_MANAGER:RegisterForUpdate(TTUI.name, 1000, TTUI.OnUpdate)
