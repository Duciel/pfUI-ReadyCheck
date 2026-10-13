-- pfUI-ReadyCheck: ready check button integrated into pfUI
-- Only visible when you are raid leader / assistant (or party leader, optional).
-- Movable through "/pfui unlock" (pfUI unlock mode).
-- Optional "Pull" button next to it that runs BigWigs' "/pull X".

pfUI:RegisterModule("readycheckbutton", function()
  -- default values (does not overwrite already saved values)
  pfUI:UpdateConfig("readycheckbutton", nil, "enable", "1")
  pfUI:UpdateConfig("readycheckbutton", nil, "party",  "1")
  pfUI:UpdateConfig("readycheckbutton", nil, "width",  "90")
  pfUI:UpdateConfig("readycheckbutton", nil, "height", "22")
  pfUI:UpdateConfig("readycheckbutton", nil, "text",   "Ready Check")
  pfUI:UpdateConfig("readycheckbutton", nil, "pull",      "1")
  pfUI:UpdateConfig("readycheckbutton", nil, "pulltime",  "10")
  pfUI:UpdateConfig("readycheckbutton", nil, "pullwidth", "60")

  local cfg = C.readycheckbutton

  local function CanReadyCheck()
    if GetNumRaidMembers() > 0 then
      return IsRaidLeader() or IsRaidOfficer()
    elseif GetNumPartyMembers() > 0 then
      return cfg.party == "1" and IsPartyLeader()
    end
    return nil
  end

  -- runs a slash command registered by another addon (e.g. BigWigs' /pull)
  local function RunSlashCommand(cmd, args)
    cmd = string.lower(cmd)
    for key, handler in pairs(SlashCmdList) do
      local i = 1
      local slash = _G["SLASH_" .. key .. i]
      while slash do
        if string.lower(slash) == cmd then
          handler(args or "")
          return true
        end
        i = i + 1
        slash = _G["SLASH_" .. key .. i]
      end
    end
    return nil
  end

  local function PullTime()
    local t = tonumber(cfg.pulltime)
    if not t or t < 1 then t = 10 end
    return math.floor(t)
  end

  local function StartPull(seconds)
    if not RunSlashCommand("/pull", tostring(seconds)) then
      DEFAULT_CHAT_FRAME:AddMessage("|cff33ffccpf|rReadyCheck: /pull command not found (is BigWigs loaded?).")
    end
  end

  local b = CreateFrame("Button", "pfReadyCheckButton", UIParent)
  b:SetFrameStrata("MEDIUM")
  b:SetPoint("TOP", UIParent, "TOP", 0, -120)
  b:RegisterForClicks("LeftButtonUp", "RightButtonUp")

  b.text = b:CreateFontString(nil, "OVERLAY")
  b.text:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
  b.text:SetPoint("CENTER", 0, 0)

  SkinButton(b)

  -- pull button: child of the ready check button, so it moves and hides with it
  local p = CreateFrame("Button", "pfReadyCheckPullButton", b)
  p:SetPoint("LEFT", b, "RIGHT", 4, 0)
  p:RegisterForClicks("LeftButtonUp", "RightButtonUp")

  p.text = p:CreateFontString(nil, "OVERLAY")
  p.text:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
  p.text:SetPoint("CENTER", 0, 0)

  SkinButton(p)

  p:SetScript("OnClick", function()
    if not CanReadyCheck() then
      DEFAULT_CHAT_FRAME:AddMessage("|cff33ffccpf|rReadyCheck: you must be leader or assistant.")
      return
    end
    if arg1 == "RightButton" then
      StartPull(0) -- cancel the running pull timer
    else
      StartPull(PullTime())
    end
  end)

  p:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_BOTTOM")
    GameTooltip:SetText("Pull Timer")
    GameTooltip:AddLine("Left-click: /pull " .. PullTime(), 1, 1, 1)
    GameTooltip:AddLine("Right-click: cancel pull (/pull 0)", 1, 1, 1)
    GameTooltip:Show()
  end)
  p:SetScript("OnLeave", function() GameTooltip:Hide() end)

  b.Update = function()
    b:SetWidth(tonumber(cfg.width) or 90)
    b:SetHeight(tonumber(cfg.height) or 22)
    b.text:SetText(cfg.text)

    p:SetWidth(tonumber(cfg.pullwidth) or 60)
    p:SetHeight(tonumber(cfg.height) or 22)
    p.text:SetText("Pull " .. PullTime())
    if cfg.pull == "1" then p:Show() else p:Hide() end

    -- in unlock mode, pfUI handles visibility itself
    if pfUI.unlock and pfUI.unlock:IsShown() then return end

    if cfg.enable == "1" and CanReadyCheck() then
      b:Show()
    else
      b:Hide()
    end
  end

  b:SetScript("OnClick", function()
    if not CanReadyCheck() then
      DEFAULT_CHAT_FRAME:AddMessage("|cff33ffccpf|rReadyCheck: you must be leader or assistant.")
      return
    end
    if arg1 == "RightButton" then
      -- right click: announce in raid warning / raid / party before the ready check
      SendChatMessageWide("Ready check! Check your consumables.")
    end
    DoReadyCheck()
  end)

  b:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_BOTTOM")
    GameTooltip:SetText("Ready Check")
    GameTooltip:AddLine("Left-click: start a ready check", 1, 1, 1)
    GameTooltip:AddLine("Right-click: announce + ready check", 1, 1, 1)
    GameTooltip:AddLine("/pfui unlock to move", .6, .6, .6)
    GameTooltip:Show()
  end)
  b:SetScript("OnLeave", function() GameTooltip:Hide() end)

  b:RegisterEvent("PLAYER_ENTERING_WORLD")
  b:RegisterEvent("RAID_ROSTER_UPDATE")
  b:RegisterEvent("PARTY_MEMBERS_CHANGED")
  b:RegisterEvent("PARTY_LEADER_CHANGED")
  b:SetScript("OnEvent", function() b.Update() end)

  -- saved position + pfUI unlock mode integration
  UpdateMovable(b)
  b.Update()

  -- entry in the pfUI config menu (/pfui > Thirdparty > Ready Check)
  if pfUI.gui and pfUI.gui.CreateGUIEntry then
    local U = function() b.Update() end
    pfUI.gui.CreateGUIEntry(T["Thirdparty"], "Ready Check", function()
      pfUI.gui.CreateConfig(U, "Enable Button", cfg, "enable", "checkbox")
      pfUI.gui.CreateConfig(U, "Also Show In Party (Leader)", cfg, "party", "checkbox")
      pfUI.gui.CreateConfig(U, "Button Text", cfg, "text")
      pfUI.gui.CreateConfig(U, "Width", cfg, "width")
      pfUI.gui.CreateConfig(U, "Height", cfg, "height")
      pfUI.gui.CreateConfig(nil, "Pull Timer", nil, nil, "header")
      pfUI.gui.CreateConfig(U, "Show Pull Button", cfg, "pull", "checkbox")
      pfUI.gui.CreateConfig(U, "Pull Timer (Seconds)", cfg, "pulltime")
      pfUI.gui.CreateConfig(U, "Pull Button Width", cfg, "pullwidth")
    end)
  end

  -- slash commands: /rc (ready check), /rcpull (pull with configured time)
  _G.SLASH_PFREADYCHECK1 = "/rc"
  _G.SlashCmdList["PFREADYCHECK"] = function()
    if CanReadyCheck() then DoReadyCheck() end
  end
  _G.SLASH_PFREADYCHECKPULL1 = "/rcpull"
  _G.SlashCmdList["PFREADYCHECKPULL"] = function()
    if CanReadyCheck() then StartPull(PullTime()) end
  end
end)
