UI = {}
UI.name = "KharfUI"

local classIcons = {
	[1] = [[/esoui/art/icons/class/class_dragonknight.dds]],
	[2] = [[/esoui/art/icons/class/class_sorcerer.dds]],
	[3] = [[/esoui/art/icons/class/class_nightblade.dds]],
	[4] = [[/esoui/art/icons/class/class_warden.dds]],
	[6] = [[/esoui/art/icons/class/class_templar.dds]],
}

local allianceIcons = {
	[100] = [[/esoui/art/ava/ava_allianceflag_neutral.dds]],
	[1] = [[/esoui/art/guild/guildbanner_icon_aldmeri.dds]],
	[2] = [[/esoui/art/guild/guildbanner_icon_ebonheart.dds]],
	[3] = [[/esoui/art/guild/guildbanner_icon_daggerfall.dds]],
}

function UI.OnAddOnLoaded(event, addonName)
  if addonName == UI.name then
    UI.InitializeControls()
    UI.HideControls()
    UI.AddUiAsFragment()
    UI.Initialize()
    EVENT_MANAGER:UnregisterForEvent(UI.name, EVENT_ADD_ON_LOADED)
  end
end

function UI.OnPlayerLoaded()
  EVENT_MANAGER:UnregisterForEvent(UI.name, EVENT_PLAYER_ACTIVATED)
  CHAT_SYSTEM:AddMessage("KharfUI by @Kharf")
end

function UI.OnUpdate()
  UnitFramesInfoRightBlockFPSLabel:SetText(string.format("%d fps & %s ms", GetFramerate(), GetLatency()))
  UnitFramesInfoRightBlockTimeLabel:SetText(string.format("%s", GetTimeString()))
end

function UI.Initialize()
  UI.InitUnitPower("player")
  UI.InitializeGroup()
end

function UI.InitializeGroup()
  for i = 1, 4 do
    unitTag = "group" .. i
    if DoesUnitExist(unitTag) then
      UI.InitUnitPower(unitTag)
    else
      UI.SetHidden(unitTag, true)
    end
  end
end

function UI.InitializeControls()
  unitFrames = {
    ["player"] = UnitFramesPlayer,
    ["reticleover"] = UnitFramesTarget,
    ["group1"] = UnitFramesGroup1,
    ["group2"] = UnitFramesGroup2,
    ["group3"] = UnitFramesGroup3,
    ["group4"] = UnitFramesGroup4
  }
  powertype_controls = {}
  powertype_controls["player"] = {
    ["HEALTH_SHIELD_CURRENT_LABEL"] = UnitFramesPlayerHealthShieldValueLabel,
    ["HEALTH_CURRENT_LABEL"] = UnitFramesPlayerHealthValueLabel,
    ["HEALTH_BAR"] = UnitFramesPlayerHealthBar,
    ["MAGICKA_CURRENT_LABEL"] = UnitFramesPlayerMagickaValueLabel,
    ["MAGICKA_BAR"] = UnitFramesPlayerMagickaBar,
    ["STAMINA_CURRENT_LABEL"] = UnitFramesPlayerStaminaValueLabel,
    ["STAMINA_BAR"] = UnitFramesPlayerStaminaBar
  }
  powertype_controls["reticleover"] = {
    ["RANK"] = UnitFramesTargetRank,
    ["NAME"] = UnitFramesTargetInfoName,
    ["CLASS_ICON"] = UnitFramesTargetClassIcon,
    ["CHAMPION_ICON"] = UnitFramesTargetChampionIcon,
    ["RACE"] = UnitFramesTargetRace,
    ["HEALTH_SHIELD_CURRENT_LABEL"] = UnitFramesTargetHealthShieldValueLabel,
    ["HEALTH_CURRENT_LABEL"] = UnitFramesTargetHealthValueLabel,
    ["HEALTH_BAR"] = UnitFramesTargetHealthBar
  }

  for i = 1, 4 do
    powertype_controls["group" .. i] = {
      ["NAME"] = WINDOW_MANAGER:GetControlByName("UnitFramesGroup" .. i .. "Name"),
      ["HEALTH"] = WINDOW_MANAGER:GetControlByName("UnitFramesGroup" .. i .. "Health"),
      ["HEALTH_CURRENT_LABEL"] = WINDOW_MANAGER:GetControlByName("UnitFramesGroup" .. i .. "HealthValueLabel"),
      ["HEALTH_SHIELD_CURRENT_LABEL"] = WINDOW_MANAGER:GetControlByName(
        "UnitFramesGroup" .. i .. "HealthShieldValueLabel"
      ),
      ["HEALTH_BAR"] = WINDOW_MANAGER:GetControlByName("UnitFramesGroup" .. i .. "HealthBar"),
      ["HEALTH_BORDER"] = WINDOW_MANAGER:GetControlByName("UnitFramesGroup" .. i .. "HealthBorder"),
      ["HEALTH_BACKDROP"] = WINDOW_MANAGER:GetControlByName("UnitFramesGroup" .. i .. "HealthBackdrop")
    }
  end
end

function UI.OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
  if powertype_controls == nil then
    return
  end

  if unitTag == "player" then
    if powerType == POWERTYPE_HEALTH then
      powertype_controls[unitTag]["HEALTH_BAR"]:SetMinMax(0, powerEffectiveMax)
      powertype_controls[unitTag]["HEALTH_BAR"]:SetValue(powerValue)
      UI.SetPowerStatusValue(unitTag, "HEALTH", powerValue, powerEffectiveMax)
    end
    if powerType == POWERTYPE_MAGICKA then
      powertype_controls[unitTag]["MAGICKA_BAR"]:SetMinMax(0, powerEffectiveMax)
      powertype_controls[unitTag]["MAGICKA_BAR"]:SetValue(powerValue)
      UI.SetPowerStatusValue(unitTag, "MAGICKA", powerValue, powerEffectiveMax)
    end
    if powerType == POWERTYPE_STAMINA then
      powertype_controls[unitTag]["STAMINA_BAR"]:SetMinMax(0, powerEffectiveMax)
      powertype_controls[unitTag]["STAMINA_BAR"]:SetValue(powerValue)
      UI.SetPowerStatusValue(unitTag, "STAMINA", powerValue, powerEffectiveMax)
    end
  end
  if unitTag == "reticleover" then
    powertype_controls[unitTag]["HEALTH_BAR"]:SetMinMax(0, powerEffectiveMax)
    powertype_controls[unitTag]["HEALTH_BAR"]:SetValue(powerValue)
    UI.SetPowerStatusValue(unitTag, "HEALTH", powerValue, powerEffectiveMax)
  end
  if unitTag == "group1" or unitTag == "group2" or unitTag == "group3" or unitTag == "group4" then
    powertype_controls[unitTag]["HEALTH_BAR"]:SetMinMax(0, powerEffectiveMax)
    powertype_controls[unitTag]["HEALTH_BAR"]:SetValue(powerValue)
    UI.SetPowerStatusValue(unitTag, "HEALTH", powerValue, powerEffectiveMax)
  end
end

function UI.OnVisualAdded(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
  if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
    if unitTag == "player" then
      local shieldColor = ZO_ColorDef:New("8f8f8f")
      powertype_controls[unitTag]["HEALTH_BAR"]:SetColor(shieldColor:UnpackRGBA())
      powertype_controls[unitTag]["HEALTH_SHIELD_CURRENT_LABEL"]:SetText(string.format("(%d)", value))
    end
    if unitTag == "reticleover" then
      local shieldColor = ZO_ColorDef:New("8f8f8f")
      powertype_controls[unitTag]["HEALTH_BAR"]:SetColor(shieldColor:UnpackRGBA())
      powertype_controls[unitTag]["HEALTH_SHIELD_CURRENT_LABEL"]:SetText(string.format("(%d)", value))
    end
    if unitTag == "group1" or unitTag == "group2" or unitTag == "group3" or unitTag == "group4" then
      local shieldColor = ZO_ColorDef:New("8f8f8f")
      powertype_controls[unitTag]["HEALTH_BAR"]:SetColor(shieldColor:UnpackRGBA())
      powertype_controls[unitTag]["HEALTH_SHIELD_CURRENT_LABEL"]:SetText(string.format("(%d)", value))
    end
  end
end

function UI.OnVisualUpdated(
  eventCode,
  unitTag,
  unitAttributeVisual,
  statType,
  attributeType,
  powerType,
  oldValue,
  newValue,
  value,
  maxValue)
  if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
    if unitTag == "player" then
      powertype_controls[unitTag]["HEALTH_SHIELD_CURRENT_LABEL"]:SetText(string.format("(%d)", newValue))
    end
    if unitTag == "reticleover" then
      powertype_controls[unitTag]["HEALTH_SHIELD_CURRENT_LABEL"]:SetText(string.format("(%d)", newValue))
    end
    if unitTag == "group1" or unitTag == "group2" or unitTag == "group3" or unitTag == "group4" then
      powertype_controls[unitTag]["HEALTH_SHIELD_CURRENT_LABEL"]:SetText(string.format("(%d)", newValue))
    end
  end
end

function UI.OnVisualRemoved(
  eventCode,
  unitTag,
  unitAttributeVisual,
  statType,
  attributeType,
  powerType,
  value,
  maxValue)
  if powertype_controls == nil then
    return
  end
  if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
    if unitTag == "player" then
      local backToHealthColor = ZO_ColorDef:New("933f3f")
      powertype_controls[unitTag]["HEALTH_BAR"]:SetColor(backToHealthColor:UnpackRGBA())
      powertype_controls[unitTag]["HEALTH_SHIELD_CURRENT_LABEL"]:SetText("")
    end
    if unitTag == "reticleover" then
      local backToHealthColor = ZO_ColorDef:New("933f3f")
      powertype_controls[unitTag]["HEALTH_BAR"]:SetColor(backToHealthColor:UnpackRGBA())
      powertype_controls[unitTag]["HEALTH_SHIELD_CURRENT_LABEL"]:SetText("")
    end
    if unitTag == "group1" or unitTag == "group2" or unitTag == "group3" or unitTag == "group4" then
      local backToHealthColor = ZO_ColorDef:New("933f3f")
      powertype_controls[unitTag]["HEALTH_BAR"]:SetColor(backToHealthColor:UnpackRGBA())
      powertype_controls[unitTag]["HEALTH_SHIELD_CURRENT_LABEL"]:SetText("")
    end
  end
end

function UI.OnTargetChanged(eventCode)
  if DoesUnitExist("reticleover") then
    unitFrames["reticleover"]:SetHidden(false)
    UI.InitUnitPower("reticleover")
  else
    unitFrames["reticleover"]:SetHidden(true)
  end
end

function UI.OnPlayerRez(eventCode)
  UI.InitUnitPower("player")
  UI.InitializeGroup()
end

function UI.InitUnitPower(unitTag)
  local currentHealth, maxHealth, effectiveMaxHealth = GetUnitPower(unitTag, POWERTYPE_HEALTH)
  local currentMagicka, maxMagicka, effectiveMaxMagicka = GetUnitPower(unitTag, POWERTYPE_MAGICKA)
  local currentStamina, maxStamina, effectiveMaxStamina = GetUnitPower(unitTag, POWERTYPE_STAMINA)
  local shield, _ =
    GetUnitAttributeVisualizerEffectInfo(
    unitTag,
    ATTRIBUTE_VISUAL_POWER_SHIELDING,
    STAT_MITIGATION,
    ATTRIBUTE_HEALTH,
    POWERTYPE_HEALTH
  )
  if unitTag == "player" then
    if shield == nil then
      powertype_controls[unitTag]["HEALTH_SHIELD_CURRENT_LABEL"]:SetText("")
      local backToHealthColor = ZO_ColorDef:New("933f3f")
      powertype_controls[unitTag]["HEALTH_BAR"]:SetColor(backToHealthColor:UnpackRGBA())
    else
      powertype_controls[unitTag]["HEALTH_SHIELD_CURRENT_LABEL"]:SetText(string.format("(%d)", shield))
      local shieldColor = ZO_ColorDef:New("8f8f8f")
      powertype_controls[unitTag]["HEALTH_BAR"]:SetColor(shieldColor:UnpackRGBA())
    end
    powertype_controls[unitTag]["HEALTH_BAR"]:SetMinMax(0, maxHealth)
    powertype_controls[unitTag]["HEALTH_BAR"]:SetValue(currentHealth)
    UI.SetPowerStatusValue(unitTag, "HEALTH", currentHealth, effectiveMaxHealth)

    powertype_controls[unitTag]["MAGICKA_BAR"]:SetMinMax(0, maxMagicka)
    powertype_controls[unitTag]["MAGICKA_BAR"]:SetValue(currentMagicka)
    UI.SetPowerStatusValue(unitTag, "MAGICKA", currentMagicka, effectiveMaxMagicka)

    powertype_controls[unitTag]["STAMINA_BAR"]:SetMinMax(0, maxStamina)
    powertype_controls[unitTag]["STAMINA_BAR"]:SetValue(currentStamina)
    UI.SetPowerStatusValue(unitTag, "STAMINA", currentStamina, effectiveMaxStamina)
  end
  if unitTag == "reticleover" then
    local unitAlliance = GetUnitAlliance(unitTag)
    if shield == nil then
      powertype_controls[unitTag]["HEALTH_SHIELD_CURRENT_LABEL"]:SetText("")
      if unitAlliance == 1 then
        local backToHealthColor = ZO_ColorDef:New("b2984a")
        powertype_controls[unitTag]["HEALTH_BAR"]:SetColor(backToHealthColor:UnpackRGBA())
      end
      if unitAlliance == 2 then
        local backToHealthColor = ZO_ColorDef:New("973735")
        powertype_controls[unitTag]["HEALTH_BAR"]:SetColor(backToHealthColor:UnpackRGBA())
      end
      if unitAlliance == 3 then
        local backToHealthColor = ZO_ColorDef:New("587d9f")
        powertype_controls[unitTag]["HEALTH_BAR"]:SetColor(backToHealthColor:UnpackRGBA())
      end
    else
      powertype_controls[unitTag]["HEALTH_SHIELD_CURRENT_LABEL"]:SetText(string.format("(%d)", shield))
      local shieldColor = ZO_ColorDef:New("8f8f8f")
      powertype_controls[unitTag]["HEALTH_BAR"]:SetColor(shieldColor:UnpackRGBA())
    end
    powertype_controls[unitTag]["HEALTH_BAR"]:SetMinMax(0, maxHealth)
    powertype_controls[unitTag]["HEALTH_BAR"]:SetValue(currentHealth)
    local cp = GetUnitChampionPoints(unitTag)
    powertype_controls[unitTag]["NAME"]:SetText(GetUnitName(unitTag))
    --powertype_controls[unitTag]["DISPLAY_NAME"]:SetText(GetUnitDisplayName(unitTag))
    powertype_controls[unitTag]["RACE"]:SetText(GetUnitRace(unitTag))
    if IsUnitPlayer(unitTag) then
      powertype_controls[unitTag]["CLASS_ICON"]:SetTexture(classIcons[GetUnitClassId(unitTag)])
      powertype_controls[unitTag]["CLASS_ICON"]:SetHidden(false)
      powertype_controls[unitTag]["RANK"]:SetHidden(false)
      if IsUnitChampion(unitTag) then
        powertype_controls[unitTag]["RANK"]:SetText(cp)
        powertype_controls[unitTag]["CHAMPION_ICON"]:SetHidden(false)
      else
        powertype_controls[unitTag]["RANK"]:SetText(GetUnitLevel(unitTag))
        powertype_controls[unitTag]["CHAMPION_ICON"]:SetHidden(true)
      end
    else 
      powertype_controls[unitTag]["CLASS_ICON"]:SetHidden(true)
      powertype_controls[unitTag]["RANK"]:SetHidden(true)
      powertype_controls[unitTag]["CHAMPION_ICON"]:SetHidden(true)
    end
    UI.SetPowerStatusValue(unitTag, "HEALTH", currentHealth, effectiveMaxHealth)
  end
  if unitTag == "group1" or unitTag == "group2" or unitTag == "group3" or unitTag == "group4" then
    UI.SetHidden(unitTag, false)
    if IsUnitOnline(unitTag) then
      powertype_controls[unitTag]["NAME"]:SetText(GetUnitName(unitTag))
      if shield == nil then
        local backToHealthColor = ZO_ColorDef:New("933f3f")
        powertype_controls[unitTag]["HEALTH_BAR"]:SetColor(backToHealthColor:UnpackRGBA())
      else
        powertype_controls[unitTag]["HEALTH_SHIELD_CURRENT_LABEL"]:SetText(string.format("(%d)", shield))
        local shieldColor = ZO_ColorDef:New("8f8f8f")
        powertype_controls[unitTag]["HEALTH_BAR"]:SetColor(shieldColor:UnpackRGBA())
      end
    else
      powertype_controls[unitTag]["NAME"]:SetText(GetUnitName(unitTag) .. " - offline")
      local offlineColor = ZO_ColorDef:New("1a1a1a")
      powertype_controls[unitTag]["HEALTH_BAR"]:SetColor(offlineColor:UnpackRGBA())
    end
    powertype_controls[unitTag]["HEALTH_BAR"]:SetMinMax(0, maxHealth)
    powertype_controls[unitTag]["HEALTH_BAR"]:SetValue(currentHealth)
    UI.SetPowerStatusValue(unitTag, "HEALTH", currentHealth, effectiveMaxHealth)
  end
end

function UI.SetPowerStatusValue(unitTag, type, current, effective)
  if unitTag == "player" then
    powertype_controls[unitTag][type .. "_CURRENT_LABEL"]:SetText(string.format("%s / %s", current, effective))
  end
  if unitTag == "reticleover" then
    powertype_controls[unitTag][type .. "_CURRENT_LABEL"]:SetText(string.format("%s / %s", current, effective))
  end
  if unitTag == "group1" or unitTag == "group2" or unitTag == "group3" or unitTag == "group4" then
    powertype_controls[unitTag][type .. "_CURRENT_LABEL"]:SetText(string.format("%s / %s", current, effective))
  end
end

function UI.HideControls()
  ZO_UnitFramesGroups:SetHidden(true)
  ZO_PlayerAttributeMagicka:UnregisterForEvent(EVENT_POWER_UPDATE)
  ZO_PlayerAttributeMagicka:UnregisterForEvent(EVENT_INTERFACE_SETTING_CHANGED)
  ZO_PlayerAttributeMagicka:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
  EVENT_MANAGER:UnregisterForUpdate("ZO_PlayerAttributeMagickaFadeUpdate")
  ZO_PlayerAttributeMagicka:SetHidden(true)
  
  ZO_PlayerAttributeStamina:UnregisterForEvent(EVENT_POWER_UPDATE)
  ZO_PlayerAttributeStamina:UnregisterForEvent(EVENT_INTERFACE_SETTING_CHANGED)
  ZO_PlayerAttributeStamina:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
  EVENT_MANAGER:UnregisterForUpdate("ZO_PlayerAttributeStaminaFadeUpdate")
  ZO_PlayerAttributeStamina:SetHidden(true)
  
  ZO_PlayerAttributeHealth:UnregisterForEvent(EVENT_POWER_UPDATE)
  ZO_PlayerAttributeHealth:UnregisterForEvent(EVENT_INTERFACE_SETTING_CHANGED)
  ZO_PlayerAttributeHealth:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
  EVENT_MANAGER:UnregisterForUpdate("ZO_PlayerAttributeHealthFadeUpdate")
  ZO_PlayerAttributeHealth:SetHidden(true)
  
  ZO_PlayerAttributeMountStamina:UnregisterForEvent(EVENT_POWER_UPDATE)
  ZO_PlayerAttributeMountStamina:UnregisterForEvent(EVENT_INTERFACE_SETTING_CHANGED)
  ZO_PlayerAttributeMountStamina:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
  EVENT_MANAGER:UnregisterForUpdate("ZO_PlayerAttributeMountStamina")
  ZO_PlayerAttributeMountStamina:SetHidden(true)

 --[[  ZO_TargetUnitFramereticleover:SetHidden(true)
  ZO_TargetUnitFramereticleoverBarLeft:SetHidden(true)
  ZO_TargetUnitFramereticleoverBarLeftGloss:SetHidden(true)
  ZO_TargetUnitFramereticleoverBarRight:SetHidden(true)
  ZO_TargetUnitFramereticleoverBarRightGloss:SetHidden(true)
  ZO_TargetUnitFramereticleoverBgContainer:SetHidden(true)
  ZO_TargetUnitFramereticleoverBgContainerBgCenter:SetHidden(true)
  ZO_TargetUnitFramereticleoverBgContainerBgLeft:SetHidden(true)
  ZO_TargetUnitFramereticleoverBgContainerBgRight:SetHidden(true)
  ZO_TargetUnitFramereticleoverCaption:SetHidden(true)
  ZO_TargetUnitFramereticleoverFrameCenter:SetHidden(true)
  ZO_TargetUnitFramereticleoverFrameCenterBottomMunge:SetHidden(true)
  ZO_TargetUnitFramereticleoverFrameCenterTopMunge:SetHidden(true)
  ZO_TargetUnitFramereticleoverFrameLeft:SetHidden(true)
  ZO_TargetUnitFramereticleoverFrameRight:SetHidden(true)
  ZO_TargetUnitFramereticleoverLeftBracket:SetHidden(true)
  ZO_TargetUnitFramereticleoverLeftBracketGlow:SetHidden(true)
  ZO_TargetUnitFramereticleoverLeftBracketUnderlay:SetHidden(true)
  ZO_TargetUnitFramereticleoverLevel:SetHidden(true)
  ZO_TargetUnitFramereticleoverName:SetHidden(true)
  ZO_TargetUnitFramereticleoverRankIcon:SetHidden(true)
  ZO_TargetUnitFramereticleoverRightBracket:SetHidden(true)
  ZO_TargetUnitFramereticleoverRightBracketGlow:SetHidden(true)
  ZO_TargetUnitFramereticleoverRightBracketUnderlay:SetHidden(true)
  ZO_TargetUnitFramereticleoverTextArea:SetHidden(true)
  ZO_TargetUnitFramereticleoverWarner:SetHidden(true) ]]
  --UI.HideCompass(true)
end

function UI.HideCompass(hide)
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

function UI.AddUiAsFragment()
  for key, value in pairs(unitFrames) do
    local fragment = ZO_FadeSceneFragment:New(value)
    SCENE_MANAGER:GetScene("hud"):AddFragment(fragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment)
  end
end

function UI.SetHidden(unitTag, value)
  powertype_controls[unitTag]["HEALTH"]:SetHidden(value)
  powertype_controls[unitTag]["NAME"]:SetHidden(value)
end

function UI.OnGroupMemberJoined(eventCode, name)
  UI.InitializeGroup()
end

function UI.OnGroupMemberLeft(eventCode, name)
  UI.InitializeGroup()
end

function UI.OnGroupMemberConnectionChanged(eventCode, unitTag, isOnline)
  UI.InitializeGroup()
end

EVENT_MANAGER:RegisterForEvent(UI.name, EVENT_ADD_ON_LOADED, UI.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(UI.name, EVENT_PLAYER_ACTIVATED, UI.OnPlayerLoaded)
EVENT_MANAGER:RegisterForEvent(UI.name, EVENT_POWER_UPDATE, UI.OnPowerUpdate)
EVENT_MANAGER:RegisterForEvent(UI.name, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, UI.OnVisualAdded)
EVENT_MANAGER:RegisterForEvent(UI.name, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, UI.OnVisualRemoved)
EVENT_MANAGER:RegisterForEvent(UI.name, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, UI.OnVisualUpdated)
EVENT_MANAGER:RegisterForEvent(UI.name, EVENT_RETICLE_TARGET_CHANGED, UI.OnTargetChanged)
EVENT_MANAGER:RegisterForEvent(UI.name, EVENT_PLAYER_ALIVE, UI.OnPlayerRez)
EVENT_MANAGER:RegisterForEvent(UI.name, EVENT_GROUP_MEMBER_JOINED, UI.OnGroupMemberJoined)
EVENT_MANAGER:RegisterForEvent(UI.name, EVENT_GROUP_MEMBER_LEFT, UI.OnGroupMemberLeft)
EVENT_MANAGER:RegisterForEvent(UI.name, EVENT_GROUP_MEMBER_CONNECTED_STATUS, UI.OnGroupMemberConnectionChanged)
EVENT_MANAGER:RegisterForUpdate(UI.name, 1000, UI.OnUpdate)
