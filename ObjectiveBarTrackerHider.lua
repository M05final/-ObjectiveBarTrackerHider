-- Define the SavedVariables table
autoHideSettings = autoHideSettings or { 
    autoHideEnabled = true, 
    popupShown = false, 
    lastVersion = "1.0.0",
    showMessages = true
}
local addonName, addonTable = ...

-- Define the version of the addon
local addonVersion = "1.0.0"

-- Function to hide the objective tracker
local function HideObjectiveTracker()
    ObjectiveTrackerFrame:UnregisterAllEvents()
    ObjectiveTrackerFrame:Hide()
    ObjectiveTrackerFrame:SetScript("OnShow", ObjectiveTrackerFrame.Hide)  -- Prevent it from showing again
end

-- Function to show help information for the addon
local function ShowHelp()
    print("|cffffa500Disable Objective Tracker v" .. addonVersion .. " - Help|r")
    print()
    print("|cffffa500/ot|r          - Toggle the visibility of the Objective Tracker")
    print("|cffffa500/ot show|r     - Show the Objective Tracker")
    print("|cffffa500/ot hide|r     - Hide the Objective Tracker")
    print("|cffffa500/ot auto|r     - Show the current auto-hiding status (currently " .. (autoHideSettings.autoHideEnabled and "|cFF00FF00enabled|r" or "|cFFFF0000disabled|r") .. ")")
    print("|cffffa500/ot auto on|r  - Enable auto-hiding")
    print("|cffffa500/ot auto off|r - Disable auto-hiding")
    print("|cffffa500/ot message|r   - Show the current startup messages status (currently " .. (autoHideSettings.showMessages and "|cFF00FF00enabled|r" or "|cFFFF0000disabled|r") .. ")")
    print("|cffffa500/ot message on|r - Enable startup messages")
    print("|cffffa500/ot message off|r - Disable startup messages")
    print("|cffffa500/ot info|r     - Show the popup window with addon information")
end


-- Function to show the objective tracker
local function ShowObjectiveTracker()
    -- Re-register events needed for the objective tracker
    ObjectiveTrackerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    ObjectiveTrackerFrame:RegisterEvent("QUEST_LOG_UPDATE")
    ObjectiveTrackerFrame:RegisterEvent("SCENARIO_UPDATE")
    ObjectiveTrackerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    
    -- Use a small delay to ensure the tracker has time to be hidden before showing again
    C_Timer.After(0.1, function()
        ObjectiveTrackerFrame:Show()
    end)
    ObjectiveTrackerFrame:SetScript("OnShow", nil)  -- Allow it to show again
end

-- Function to create a custom tooltip-like popup for better control
local function ShowCustomPopup()
    -- Check if the popup already exists
    if _G["CustomPopup"] then
        _G["CustomPopup"]:Show()
        return
    end

    local frame = CreateFrame("Frame", "CustomPopup", UIParent, "BackdropTemplate")
    frame:SetSize(600, 380)  -- Set size to fit the text
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 300)  -- Center on the screen with a higher offset

    -- Dark solid black background
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",  -- Solid black texture
        edgeFile = nil, 
        tile = true, tileSize = 32, edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    frame:SetBackdropColor(0, 0, 0, 0.75)  -- Set black background with slightly more transparency

    -- Close button
    local button = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    button:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
    button:SetSize(120, 30)
    button:SetText("OK")
    button:SetScript("OnClick", function()
        frame:Hide()
    end)

    -- Text area
    local text = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    text:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)  -- Align text to the left with some margin
    text:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 50)  -- Allow text to wrap within the frame
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    text:SetText("                                              Welcome to Disable Objective Tracker v1.0.0!\n\n" .. 
             "               |cffffa500Thank you for installing my addon. Here's a quick overview of what you can do:\n\n" .. 
             "              |cffffffffCommands:\n\n" .. 
             "                  |cffffa500/ot|r                               - Toggle the visibility of the Objective Tracker\n" .. 
             "                  |cffffa500/ot show|r                     - Show the Objective Tracker\n" .. 
             "                  |cffffa500/ot hide|r                       - Hide the Objective Tracker\n" .. 
             "                  |cffffa500/ot auto on|r                 - Enable auto-hiding\n" .. 
             "                  |cffffa500/ot auto off|r                 - Disable auto-hiding\n" .. 
             "                  |cffffa500/ot message on|r         - Enable startup messages\n" .. 
             "                  |cffffa500/ot message off|r         - Disable startup messages\n\n" .. 
             "                                  - Automatic Hiding: |cFF00FF00enabled|r (by default)\n" .. 
             "                                  - Startup Messages: |cFF00FF00enabled|r (by default)\n\n" .. 
             "For more detailed information, type |cffffa500/ot help|r.\n\n" .. 
             "|cffffa500Changelog:\n" .. 
             "- v1.0.0: Initial release\n" .. 
             "  - Basic functionality to toggle the Objective Tracker\n" .. 
             "  - Auto-hiding feature\n" .. 
             "  - Support for slash commands\n\n" .. 
             "Thank you for using Disable Objective Tracker!")




    -- Handle ESC key to close the frame
    frame:SetPropagateKeyboardInput(true)
    frame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:Hide()
            return true  -- Consume the ESC key press
        end
    end)

    -- Allow interaction with other UI elements while the popup is open
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    frame:Show()
end

-- Function to handle the slash commands
local function HandleCommand(input)
    local cmd, arg = strsplit(" ", input, 2)
    cmd = cmd:lower()

    if cmd == "show" then
        ShowObjectiveTracker()
        print("|cffffa500Objective Tracker shown.|r")
    elseif cmd == "hide" then
        HideObjectiveTracker()
        print("|cffffa500Objective Tracker hidden.|r")
    elseif cmd == "help" then
        ShowHelp()
    elseif cmd == "auto" then
        if arg == "on" then
            autoHideSettings.autoHideEnabled = true
            print("|cffffa500Automatic hiding set to |cFF00FF00enabled.|r")
        elseif arg == "off" then
            autoHideSettings.autoHideEnabled = false
            print("|cffffa500Automatic hiding set to |cFFFF0000disabled.|r")
        else
            print("|cffffa500Automatic hiding is currently set to " .. (autoHideSettings.autoHideEnabled and "|cFF00FF00enabled.|r" or "|cFFFF0000disabled.|r") .. "|r")
        end
    elseif cmd == "message" then
        if arg == "on" then
            autoHideSettings.showMessages = true
            print("|cffffa500Startup messages are |cFF00FF00enabled.|r")
        elseif arg == "off" then
            autoHideSettings.showMessages = false
            print("|cffffa500Startup messages are |cFFFF0000disabled.|r")
        else
            print("|cffffa500Startup messages are currently set to " .. (autoHideSettings.showMessages and "|cFF00FF00enabled.|r" or "|cFFFF0000disabled.|r") .. "|r")
        end
    elseif cmd == "info" then
        ShowCustomPopup()
    else
        if cmd == "" then
            if ObjectiveTrackerFrame:IsShown() then
                HideObjectiveTracker()
                print("|cffffa500Objective Tracker hidden.|r")
            else
                ShowObjectiveTracker()
                print("|cffffa500Objective Tracker shown.|r")
            end
        else
            ShowHelp()
        end
    end
end

-- Slash commands
SLASH_OT1 = "/ot"
SlashCmdList["OT"] = HandleCommand

-- Automatically hide the tracker on load if autoHideEnabled is true
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event, ...)
    if autoHideSettings.autoHideEnabled then
        HideObjectiveTracker()

        -- Add a delay before printing the message to ensure the tracker is hidden
        C_Timer.After(1, function()
            if autoHideSettings.showMessages then
                if not ObjectiveTrackerFrame:IsShown() then
                    print("|cffffa500Objective Tracker has been hidden on startup due to auto-hiding settings.|r")
                else
                    print("|cffffa500Objective Tracker was not hidden. Check if auto-hide is functioning correctly.|r")
                end
            end
        end)
    elseif autoHideSettings.showMessages then
        print("|cffffa500Auto-hide is disabled. The Objective Tracker is visible.|r")
    end

    if not autoHideSettings.popupShown then
        ShowCustomPopup()  -- Use custom popup
        autoHideSettings.popupShown = true
    elseif autoHideSettings.lastVersion ~= addonVersion then
        ShowChangelogPopup()
        autoHideSettings.lastVersion = addonVersion
    end
end)

-- Save the settings to SavedVariables
local function SaveSettings()
    autoHideSettings.autoHideEnabled = autoHideSettings.autoHideEnabled
    autoHideSettings.popupShown = autoHideSettings.popupShown
    autoHideSettings.lastVersion = addonVersion
end

local saveFrame = CreateFrame("Frame")
saveFrame:RegisterEvent("PLAYER_LOGOUT")
saveFrame:SetScript("OnEvent", SaveSettings)
