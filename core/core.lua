--[[
GuildMemes
Save and share your guildmates best quotes!
]]--

local addonName, addon = ...;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true);
local GuildMemes = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceConsole-3.0", "AceComm-3.0", "AceTimer-3.0");

-- CONFIGURATION
GuildMemes.version = "1.0.1" --[["dev"]];
GuildMemes.versionAlertSent = false

GuildMemes.COMM_PREFIX = addonName;
GuildMemes.COMM_CHANNEL = "GUILD";
GuildMemes.CURRENT_PLAYER = UnitName("player");

local options = {
    name = addonName,
    desc = L["ADDON_DESCRIPTION"],
    handler = GuildMemes,
    type = "group",
    args = {
        intro = {
            order = 1,
            type = "description",
            name = L["ADDON_DESCRIPTION"],
            cmdHidden = true
        },
        vers = {
            order = 2,
            type = "description",
            name = "|cffffd700    "..L["ADDON_VERSION"].."|r "..GuildMemes.version,
            cmdHidden = true
        },
        desc = {
            order = 3,
            type = "description",
            name = "|cffffd700    "..L["ADDON_AUTHOR"].."|r Bloojin@Hyjal-EU\n\n",
            cmdHidden = true
        },
        actionGroup = {
            order = 4,
            name = L["LABEL_ACTIONS_OPTIONS"],
            type = "group",
            inline = true,
            args = {
                openQuotes = {
                    order = 1,
                    name = L["LABEL_ACTION_OPEN_QUOTES"],
                    desc = L["LABEL_ACTION_OPEN_QUOTES_DESCRIPTION"],
                    type = "execute",
                    func = function() GuildMemes:OpenUI(); end,
                },
                syncQuotes = {
                    order = 2,
                    name = L["LABEL_ACTION_OPEN_SYNC"],
                    desc = L["LABEL_ACTION_OPEN_SYNC_DESCRIPTION"],
                    type = "execute",
                    func = function() GuildMemes:OpenUI("TAB_SYNC"); end,
                },
                resetDatabase = {
                    order = 3,
                    name = L["LABEL_ACTION_RESET_DATABASE"],
                    desc = L["LABEL_ACTION_RESET_DATABASE_DESCRIPTION"],
                    confirm = function() return L["LABEL_ACTION_RESET_DATABASE_CONFIRM"] end,
                    type = "execute",
                    func = function() GuildMemes.Database:Reset(); GuildMemes:Print(L["QUOTES_RESET"]); end,
                },
            },
        },
        syncGroup = {
            order = 5,
            name = L["LABEL_SYNC_OPTIONS"],
            type = "group",
            inline = true,
            args = {
                automaticSyncCreation = {
                    name = L["LABEL_OPTION_AUTO_SYNC_CREATION"],
                    desc = L["LABEL_OPTION_AUTO_SYNC_CREATION_DESCRIPTION"],
                    type = "toggle",
                    width = "full",
                    set = function(info,val) GuildMemes.Database:SetOption("auto_sync_creation", val); end,
                    get = function(info) return GuildMemes.Database:GetOption("auto_sync_creation"); end,
                },
                automaticSyncUpdate = {
                    name = L["LABEL_OPTION_AUTO_SYNC_UPDATE"],
                    desc = L["LABEL_OPTION_AUTO_SYNC_UPDATE_DESCRIPTION"],
                    type = "toggle",
                    width = "full",
                    set = function(info,val) GuildMemes.Database:SetOption("auto_sync_update", val); end,
                    get = function(info) return GuildMemes.Database:GetOption("auto_sync_update"); end,
                },
            },
        },
        featuresGroup = {
            order = 6,
            name = L["LABEL_FEATURES_OPTIONS"],
            type = "group",
            inline = true,
            args = {
                raidMessagePull = {
                    name = L["LABEL_OPTION_PULL_RAID_MESSAGE"],
                    desc = L["LABEL_OPTION_PULL_RAID_MESSAGE_DESCRIPTION"],
                    type = "toggle",
                    width = "full",
                    set = function(info,val) GuildMemes.Database:SetOption("quote_on_pull", val); end,
                    get = function(info) return GuildMemes.Database:GetOption("quote_on_pull"); end,
                },
            },
        },
    }
};
LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, options);
local AceConfigDialog = LibStub("AceConfigDialog-3.0");

-- DEFAULTS
local dbDefaults = {
    global = {
        quotes = {},
        options = {
            auto_sync_creation = true,
            auto_sync_update = true,
            quote_on_pull = true,
        },
    }
};

function GuildMemes:OnInitialize()
    -- init database
    GuildMemes.db = LibStub("AceDB-3.0"):New("GuildMemesDB", dbDefaults);

    -- init options
    GuildMemes.optionsFrames = AceConfigDialog:AddToBlizOptions(addonName, L["ADDON_NAME"]);
end

function GuildMemes:OnEnable()
    -- If not in a guild, this addon won't work
    if "dev" ~= addon.version and false == IsInGuild() then
        GuildMemes:PrintError(L["ERROR_NOT_IN_GUILD"]);
        return;
    end

    -- init commands
    GuildMemes:RegisterChatCommand("gm", "OnSlashCommand");
    GuildMemes:RegisterChatCommand("guildmemes", "OnSlashCommand");

    -- hook to events
    GuildMemes:RegisterComm(GuildMemes.COMM_PREFIX);
    GuildMemes:RegisterComm("D4");

    -- say hello
    GuildMemes:Print(L["ADDON_MOTD"]);

    if true == GuildMemes.Database:GetOption("auto_sync_creation") then
        GuildMemes:AskQuoteList();
    end

    GuildMemes:SendPing();
end

function GuildMemes:OnDisable()
    -- Called when the addon is disabled
end

function GuildMemes:OnSlashCommand(input)
    -- Called when the addon is disabled
    if nil ~= input and "" ~= input then
        local command, nextposition = GuildMemes:GetArgs(input, 1);
        if "add" == command then
            GuildMemes:OpenUI();
        elseif "ping" == command then
            GuildMemes:SendPing();
        end
    else
        InterfaceOptionsFrame_OpenToCategory(addonName);
        InterfaceOptionsFrame_OpenToCategory(addonName);
        --GuildMemes:OpenUI();
    end
end

-- Add a new Quote
--
-- @param string source: The name of the quote author
-- @param string content: The quote itself
-- @return Quote
function GuildMemes:AddQuote(source, content)
    local quote = GuildMemes.Quote:Create();
    quote.source = source;
    quote.quote = content;
    GuildMemes.Database:Save(quote);
    GuildMemes:SendQuote(quote);

    return quote;
end

-- Update a Quote
--
-- @param Quote quote: The quote to update
-- @param string source: The name of the quote author
-- @param string content: The quote itself
-- @return Quote
function GuildMemes:UpdateQuote(quote, source, content)
    quote.source = source;
    quote.quote = content;
    GuildMemes.Database:Save(quote);
    GuildMemes:SendQuoteUpdate(quote);

    -- remove the quote from the waiting list if we updated it
    if nil ~= GuildMemes.WaitingList:Find(quote.id) then
        GuildMemes.WaitingList:Remove(quote);
    end

    return quote;
end

function GuildMemes:OnQuoteListReceived(ids)
    for id in ids do
        GuildMemes:AskQuote(id);
    end
end

-- When a quote is received via communication, save it or add it to the waiting list depending on conf
--
-- @param Quote quote
function GuildMemes:OnQuoteReceived(quote)
    local myQuote = GuildMemes.Database:Find(quote.id);
    if nil == myQuote then
        if true == GuildMemes.Database:GetOption("auto_sync_creation") then
            GuildMemes.Database:Save(quote);
            GuildMemes:Print(L["QUOTE_ADDED"](quote.source, quote.quote));
        else
            if true == GuildMemes.WaitingList:Add(quote) then
                GuildMemes:Debug("Added to waiting list: ".. quote.quote);
            end
        end
    else
        if true == GuildMemes.Database:GetOption("auto_sync_update") then
            if quote.updatedAt > myQuote.updatedAt then
                myQuote:UpdateFrom(quote);
                GuildMemes:Print(L["QUOTE_UPDATED"](quote.source, quote.quote));
            end
        else
            if quote.updatedAt > myQuote.updatedAt then
                if true == GuildMemes.WaitingList:Add(quote, "update") then
                    GuildMemes:Debug("Added to waiting list: ".. quote.quote);
                end
            end
        end
    end
end

function GuildMemes:OnPingReceived(from, version)
    if version > GuildMemes.version and false == GuildMemes.versionAlertSent then
        GuildMemes:Print(L["ADDON_VERSION_OUTDATED"]);
        GuildMemes.versionAlertSent = true;
    end
    GuildMemes:SendPong();
end

function GuildMemes:OnPongReceived(from, version)
    GuildMemes:Debug("> |cffffd700".. from .."|r has version |cffffd700".. version .."|r");
end


function GuildMemes:PrintError(message)
    GuildMemes:Print("|cFFCC3333".. message .."|r");
end

function GuildMemes:Debug(message)
    if "dev" == self.version then
        GuildMemes:Print("|cFFAB18DB".. message .."|r");
    end
end