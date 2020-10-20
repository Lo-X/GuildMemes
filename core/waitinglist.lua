
local addonName, GuildMemes = ...;
local setmetatable = _G.setmetatable;

local WaitingList = {};
WaitingList.__index = WaitingList;

GuildMemes.quoteWaitingList = {};

-- Find and return a specific Quote in the waiting list
--
-- @param int id: The Quote id in the waiting list
-- @return Quote|nil
function WaitingList:Find(id)
    local quotes = GuildMemes.quoteWaitingList;
    for index, quote in ipairs(quotes) do
        if tonumber(quote.id) == tonumber(id) then
            return quote;
        end
    end

    return nil;
end

-- Get all quotes in waiting list
--
-- @return Quote[]
function WaitingList:FindAll()
    return GuildMemes.quoteWaitingList;
end

-- Add a new Quote to the waiting list
--
-- @param Quote quote: The Quote object to add
function WaitingList:Add(quote)
    -- new one
    if nil == self:Find(quote.id) then
        table.insert(GuildMemes.quoteWaitingList, quote);

        return true;
    end

    return false;
end

-- Removes a Quote from the waiting list
--
-- @param Quote quote: The Quote object to remove
function WaitingList:Remove(quote)
    local index = nil;
    for i, q in ipairs(GuildMemes.quoteWaitingList) do
        if quote.id == q.id then
            index = i;
        end
    end

    if nil ~= index then
        table.remove(GuildMemes.quoteWaitingList, index);
    else
        GuildMemes:PrintError("Quote {".. quote.id .."} not found in waiting list, unable to remove it");
    end
end

-- Reset the waiting list
function WaitingList:Reset()
    GuildMemes.quoteWaitingList = {};
end

GuildMemes.WaitingList = WaitingList;