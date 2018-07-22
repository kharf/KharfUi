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
    ["HEALTH_SHIELD_CURRENT_LABEL"] = UnitFramesPlayerHealthShieldValueLabel,
    ["HEALTH_CURRENT_LABEL"] = UnitFramesPlayerHealthValueLabel,
    ["HEALTH_BAR"] = UnitFramesPlayerHealthBar,
    ["MAGICKA_CURRENT_LABEL"] = UnitFramesPlayerMagickaValueLabel,
    ["MAGICKA_BAR"] = UnitFramesPlayerMagickaBar,
    ["STAMINA_CURRENT_LABEL"] = UnitFramesPlayerStaminaValueLabel,
    ["STAMINA_BAR"] = UnitFramesPlayerStaminaBar
  }
  powertype_controls.reticleover = {
    ["HEALTH_SHIELD_CURRENT_LABEL"] = UnitFramesTargetHealthShieldValueLabel,
    ["HEALTH_CURRENT_LABEL"] = UnitFramesTargetHealthValueLabel,
    ["HEALTH_BAR"] = UnitFramesTargetHealthBar
  }
end

function TTUI.OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
  if powertype_controls == nil then
    return
  end

  if unitTag == "player" then
    if powerType == POWERTYPE_HEALTH then
      powertype_controls.player["HEALTH_BAR"]:SetMinMax(0, powerEffectiveMax)
      powertype_controls.player["HEALTH_BAR"]:SetValue(powerValue)
      TTUI.SetPowerStatusValue(unitTag, "HEALTH", powerValue, powerEffectiveMax)
    end
    if powerType == POWERTYPE_MAGICKA then
      powertype_controls.player["MAGICKA_BAR"]:SetMinMax(0, powerEffectiveMax)
      powertype_controls.player["MAGICKA_BAR"]:SetValue(powerValue)
      TTUI.SetPowerStatusValue(unitTag, "MAGICKA", powerValue, powerEffectiveMax)
    end
    if powerType == POWERTYPE_STAMINA then
      powertype_controls.player["STAMINA_BAR"]:SetMinMax(0, powerEffectiveMax)
      powertype_controls.player["STAMINA_BAR"]:SetValue(powerValue)
      TTUI.SetPowerStatusValue(unitTag, "STAMINA", powerValue, powerEffectiveMax)
    end
  end
  if unitTag == "reticleover" then
    powertype_controls.reticleover["HEALTH_BAR"]:SetMinMax(0, powerEffectiveMax)
    powertype_controls.reticleover["HEALTH_BAR"]:SetValue(powerValue)
    TTUI.SetPowerStatusValue(unitTag, "HEALTH", powerValue, powerEffectiveMax)
  end
end

function TTUI.OnVisualAdded(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
  if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
    if unitTag == "player" then
      local shieldColor = ZO_ColorDef:New("8f8f8f")
      powertype_controls.player["HEALTH_BAR"]:SetColor(shieldColor:UnpackRGBA())
      powertype_controls.player["HEALTH_SHIELD_CURRENT_LABEL"]:SetText(string.format("(%6d)", value))
    end
    if unitTag == "reticleover" then
      local shieldColor = ZO_ColorDef:New("8f8f8f")
      powertype_controls.reticleover["HEALTH_BAR"]:SetColor(shieldColor:UnpackRGBA())
      powertype_controls.reticleover["HEALTH_SHIELD_CURRENT_LABEL"]:SetText(string.format("(%6d)", value))
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
      powertype_controls.player["HEALTH_SHIELD_CURRENT_LABEL"]:SetText(string.format("(%6d)", value))
    end
    if unitTag == "reticleover" then
      powertype_controls.reticleover["HEALTH_SHIELD_CURRENT_LABEL"]:SetText(string.format("(%6d)", value))
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
      powertype_controls.player["HEALTH_BAR"]:SetColor(backToHealthColor:UnpackRGBA())
      powertype_controls.player["HEALTH_SHIELD_CURRENT_LABEL"]:SetText("")
    end
    if unitTag == "reticleover" then
      local backToHealthColor = ZO_ColorDef:New("933f3f")
      powertype_controls.reticleover["HEALTH_BAR"]:SetColor(backToHealthColor:UnpackRGBA())
      powertype_controls.reticleover["HEALTH_SHIELD_CURRENT_LABEL"]:SetText("")
    end
  end
end

function TTUI.OnTargetChanged(eventCode)
  if DoesUnitExist("reticleover") then
    UnitFramesTarget:SetHidden(false)
    TTUI.InitUnitPower("reticleover")
  else
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
    powertype_controls.player["HEALTH_BAR"]:SetMinMax(0, maxHealth)
    powertype_controls.player["HEALTH_BAR"]:SetValue(currentHealth)
    TTUI.SetPowerStatusValue(unitTag, "HEALTH", currentHealth, effectiveMaxHealth)

    powertype_controls.player["MAGICKA_BAR"]:SetMinMax(0, maxMagicka)
    powertype_controls.player["MAGICKA_BAR"]:SetValue(currentMagicka)
    TTUI.SetPowerStatusValue(unitTag, "MAGICKA", currentMagicka, effectiveMaxMagicka)

    powertype_controls.player["STAMINA_BAR"]:SetMinMax(0, maxStamina)
    powertype_controls.player["STAMINA_BAR"]:SetValue(currentStamina)
    TTUI.SetPowerStatusValue(unitTag, "STAMINA", currentStamina, effectiveMaxStamina)
  end
  if unitTag == "reticleover" then
    local shield, _ =
      GetUnitAttributeVisualizerEffectInfo(
      unitTag,
      ATTRIBUTE_VISUAL_POWER_SHIELDING,
      STAT_MITIGATION,
      ATTRIBUTE_HEALTH,
      POWERTYPE_HEALTH
    )
    if shield == nil then
      powertype_controls.reticleover["HEALTH_SHIELD_CURRENT_LABEL"]:SetText("")
      local backToHealthColor = ZO_ColorDef:New("933f3f")
      powertype_controls.reticleover["HEALTH_BAR"]:SetColor(backToHealthColor:UnpackRGBA())
    else
      powertype_controls.reticleover["HEALTH_SHIELD_CURRENT_LABEL"]:SetText(string.format("(%6d)", shield))
      local shieldColor = ZO_ColorDef:New("8f8f8f")
      powertype_controls.reticleover["HEALTH_BAR"]:SetColor(shieldColor:UnpackRGBA())
    end

    powertype_controls.reticleover["HEALTH_BAR"]:SetMinMax(0, maxHealth)
    powertype_controls.reticleover["HEALTH_BAR"]:SetValue(currentHealth)
    TTUI.SetPowerStatusValue(unitTag, "HEALTH", currentHealth, effectiveMaxHealth)
  end
end

function TTUI.SetPowerStatusValue(unitTag, type, current, effective)
  if unitTag == "player" then
    powertype_controls.player[type .. "_CURRENT_LABEL"]:SetText(string.format("%6s / %6s", current, effective))
  end
  if unitTag == "reticleover" then
    powertype_controls.reticleover[type .. "_CURRENT_LABEL"]:SetText(string.format("%6s / %6s", current, effective))
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
