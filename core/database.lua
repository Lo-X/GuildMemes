
local addonName, GuildMemes = ...;
local setmetatable = _G.setmetatable;

local Database = {};
Database.__index = Database;

-- Find and return a specific Quote in the local database
--
-- @param int id: The Quote id in the database
-- @return Quote|nil
function Database:Find(id)
    local quotes = GuildMemes.db.global.quotes;
    for index, quote in ipairs(quotes) do
        if tonumber(quote.id) == tonumber(id) then
            return GuildMemes.Quote:CreateFromTable(quote);
        end
    end

    return nil;
end


-- Get all quotes in database
--
-- @return Quote[]
function Database:FindAll()
    local quotes = GuildMemes.db.global.quotes;
    local r = {};
    for index, quote in ipairs(quotes) do
        table.insert(r, GuildMemes.Quote:CreateFromTable(quote));
    end

    return r;
end


-- Add a new Quote to the database or save an existing one
--
-- @param Quote quote: The Quote object to save
function Database:Save(quote)
    -- new one
    if nil == quote.id or nil == self:Find(quote.id) then
        quote.id = quote.createdAt;
        table.insert(GuildMemes.db.global.quotes, quote);
    else
        -- the Quote is automatically persisted in database at unload
        quote.updatedAt = GetServerTime();
    end
end

-- Reset the local database
function Database:Reset()
    GuildMemes.db.global.quotes = {};
end

GuildMemes.Database = Database;