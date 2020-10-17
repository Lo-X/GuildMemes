--[[
GuildMemes
Save and share your guildmates best quotes!
]]--

local addonName, addon = ...;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true);
local GuildMemes = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceConsole-3.0", "AceComm-3.0");

-- CONFIGURATION
GuildMemes.version = --[["0.0.1"]] "dev";

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
                    name = L["LABEL_ACTION_OPEN_QUOTES"],
                    desc = L["LABEL_ACTION_OPEN_QUOTES_DESCRIPTION"],
                    type = "execute",
                    func = function() GuildMemes:OpenUI(); end,
                },
                resetDatabase = {
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
                automaticSync = {
                    name = L["LABEL_OPTION_AUTO_SYNC"],
                    desc = L["LABEL_OPTION_AUTO_SYNC_DESCRIPTION"],
                    type = "toggle",
                    width = "full",
                    set = function(info,val) GuildMemes.Database:SetOption("auto_sync", val); end,
                    get = function(info) return GuildMemes.Database:GetOption("auto_sync"); end,
                }
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
            auto_sync = true,
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

    -- say hello
    GuildMemes:Print(L["ADDON_MOTD"]);

    if true == GuildMemes.Database:GetOption("auto_sync") then
        GuildMemes:AskQuoteList();
    end
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
        elseif "reset" == command then
            GuildMemes.Database:Reset();
            GuildMemes:Print(L["QUOTES_RESET"]);
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

function GuildMemes:OnQuoteListReceived(ids)
    for id in ids do
        if nil == GuildMemes.Database:Find(id) then
            GuildMemes:AskQuote(id);
        end
    end
end

function GuildMemes:OnQuoteReceived(quote)
    if nil == GuildMemes.Database:Find(quote.id) then
        if true == GuildMemes.Database:GetOption("auto_sync") then
            GuildMemes.Database:Save(quote);
            GuildMemes:Print(L["QUOTE_ADDED"](quote.source, quote.quote));
        else
            -- @TODO add quote to waiting list
        end
    end
end

function GuildMemes:PrintError(message)
    GuildMemes:Print("|cFFCC3333".. message .."|r");
end

function GuildMemes:Debug(message)
    if "dev" == self.version then
        GuildMemes:Print("|cFFAB18DB".. message .."|r");
    end
end