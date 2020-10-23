
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
    local r = {};
    for index, quote in ipairs(GuildMemes.db.global.quotes) do
        table.insert(r, GuildMemes.Quote:CreateFromTable(quote));
    end

    return r;
end

-- Returns a random Quote from the local database
--
-- @return Quote|nil
function Database:FindRandom()
    local quotes = GuildMemes.db.global.quotes;
    local size = table.getn(quotes);
    
    if size > 0 then
        local n = random(1, size);
        
        return GuildMemes.Quote:CreateFromTable(quotes[n]);
    end

    return nil;
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

-- Upodate a Quote by copying an existing one
--
-- @param Quote quote: The up to date Quote object
function Database:UpdateFromExternal(quote)
    local myQuote = self:Find(quote.id);
    if nil ~= myQuote then
        myQuote.source = quote.source;
        myQuote.quote = quote.quote;
        myQuote.updatedAt = quote.updatedAt;
    end
end


-- Removes a Quote from the database
--
-- @param Quote quote: The Quote object to remove
function Database:Remove(quote)
    local index = nil;
    for i, q in ipairs(GuildMemes.db.global.quotes) do
        if quote.id == q.id then
            index = i;
        end
    end

    if nil ~= index then
        table.remove(GuildMemes.db.global.quotes, index);
    else
        GuildMemes:PrintError("Quote {".. quote.id .."} not found in database, unable to remove it");
    end
end


-- Reset the local database
function Database:Reset()
    GuildMemes.db.global.quotes = {};
end


function Database:SetOption(option, value)
    GuildMemes.db.global.options[option] = value;
end

function Database:GetOption(option)
    return GuildMemes.db.global.options[option];
end

GuildMemes.Database = Database;