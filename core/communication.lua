
local addonName, GuildMemes = ...;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true);

-- MESSAGES CONSTANTS
local MESSAGE_ASK_QUOTE_LIST = "ASK_QUOTE_LIST";
local MESSAGE_SEND_QUOTE_LIST = "SEND_QUOTE_LIST";
local MESSAGE_ASK_QUOTE = "ASK_QUOTE";
local MESSAGE_SEND_QUOTE = "SEND_QUOTE";
local MESSAGE_UPDATE_QUOTE = "UPDATE_QUOTE";

-- send comm message to all addon owners in the guild
function GuildMemes:SendComm(message)
    GuildMemes:SendCommMessage(GuildMemes.COMM_PREFIX, message, GuildMemes.COMM_CHANNEL);
    GuildMemes:Debug("Comm Sent // ".. message);
end

-- process the incoming message
function GuildMemes:OnCommReceived(prefix, message, distribution, sender)
    -- ignore messages we have sent
    if GuildMemes.CURRENT_PLAYER == sender then return end
    GuildMemes:Debug("Comm Received // ".. message .. " // from ".. sender);

    local command, nextposition = GuildMemes:GetArgs(message, 1);
    if MESSAGE_ASK_QUOTE_LIST == command then
        GuildMemes:SendQuoteList();
    elseif MESSAGE_SEND_QUOTE_LIST == command then
        local ids = string.gmatch(string.sub(message, nextposition), "%S+");
        GuildMemes:OnQuoteListReceived(ids);
    elseif MESSAGE_ASK_QUOTE == command then
        local id, nextposition = GuildMemes:GetArgs(string.sub(message, nextposition), 1);
        local quote = GuildMemes.Database:Find(id);
        if nil ~= quote then
            GuildMemes:SendQuote(quote);
        end
    elseif MESSAGE_SEND_QUOTE == command then
        local message = string.sub(message, nextposition);
        local quote = GuildMemes.Quote:Create();
        quote:Unpack(message);
        GuildMemes:OnQuoteReceived(quote);
    elseif MESSAGE_UPDATE_QUOTE == command then
        local message = string.sub(message, nextposition);
        local quote = GuildMemes.Quote:Create();
        quote:Unpack(message);
        GuildMemes:OnQuoteReceived(quote);
    end
end

-- ask quote list
function GuildMemes:AskQuoteList()
    GuildMemes:SendComm(MESSAGE_ASK_QUOTE_LIST);
end

-- send quote list
function GuildMemes:SendQuoteList()
    local ids = "";
    local quotes = GuildMemes.Database:FindAll();
    table.foreach(quotes, function(k, v) if v ~= nil then ids = ids .." "..v.id end end);
    GuildMemes:SendComm(MESSAGE_SEND_QUOTE_LIST .. ids);
end

-- ask quote
function GuildMemes:AskQuote(id)
    GuildMemes:SendComm(MESSAGE_ASK_QUOTE .." ".. id);
end

-- send quote
function GuildMemes:SendQuote(quote)
    local message = quote:Pack();
    GuildMemes:SendComm(MESSAGE_SEND_QUOTE .." ".. message);
end

-- update quote
function GuildMemes:SendQuoteUpdate(quote)
    local message = quote:Pack();
    GuildMemes:SendComm(MESSAGE_UPDATE_QUOTE .." ".. message);
end