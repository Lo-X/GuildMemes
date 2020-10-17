--[[
GuildMemes
Save and share your guildmates best quotes!
]]--

local addonName, addon = ...;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true);

-- ADDON INFORMATION
addon.version = --[["0.0.1"]] "dev";

local GuildMemes = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceConsole-3.0", "AceComm-3.0");

-- CONFIGURATION
GuildMemes.COMM_PREFIX = addonName;
GuildMemes.COMM_CHANNEL = "GUILD";
GuildMemes.CURRENT_PLAYER = UnitName("player");

-- DEFAULTS
local dbDefaults = {
    global = {
        quotes = {}
    }
};

function GuildMemes:OnInitialize()
    -- Beware: IsInGuild() doesn't work at initialization
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

    -- init database
    self.db = LibStub("AceDB-3.0"):New("GuildMemesDB", dbDefaults);

    -- hook to events
    GuildMemes:RegisterComm(GuildMemes.COMM_PREFIX);

    -- say hello
    GuildMemes:Print(L["ADDON_NAME"]);

    GuildMemes:AskQuoteList();
end

function GuildMemes:OnDisable()
    -- Called when the addon is disabled
end

function GuildMemes:OnSlashCommand(input)
    -- Called when the addon is disabled
    if nil ~= input and "" ~= input then
        local command, nextposition = GuildMemes:GetArgs(input, 1);
        if "reset" == command then
            GuildMemes.Database:Reset();
            GuildMemes:Print(L["QUOTES_RESET"]);
        end
    else
        GuildMemes:OpenUI();
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
        GuildMemes.Database:Save(quote);
        GuildMemes:Print(L["QUOTE_ADDED"](quote.source, quote.quote));
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