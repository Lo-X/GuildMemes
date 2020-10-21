--[[
Quote object, containing everything we want to save about a quote.
]]--

local addonName, GuildMemes = ...;
local setmetatable = _G.setmetatable;

local Quote = {
    id = nil,
    source = nil,
    quote = nil,
    addedBy = nil,
    createdAt = nil,
    updatedAt = nil,
    type = nil, -- internal use only
};
Quote.__index = Quote;

-- used to serialize and unserialize quotes
local SEPARATOR = "/#/";

-- Constructor. 'addedBy' and 'createdAt' are automatically filled
--
-- @return Quote
function Quote:Create()
    local quote = {};
    setmetatable(quote, Quote);

    quote.addedBy = GuildMemes.CURRENT_PLAYER;
    quote.createdAt = GetServerTime();
    quote.updatedAt = GetServerTime();

    return quote;
end

-- Constructor with table data, useful to transform saved data to actual objects
--
-- @param array data: key-values of a quote
-- @return Quote
function Quote:CreateFromTable(data)
    setmetatable(data, Quote);

    return data;
end

-- Update this quote from the values of another one
--
-- @param Quote quote: the Quote to copy
-- @return Quote
function Quote:UpdateFrom(quote)
    self.source = quote.source;
    self.quote = quote.quote;
    self.updatedAt = quote.updatedAt;

    return self;
end

-- Transform this quote object to a string (serialize)
--
-- @return string
function Quote:Pack()
    return self.id .. SEPARATOR .. self.source .. SEPARATOR .. self.addedBy .. SEPARATOR .. self.createdAt .. SEPARATOR .. self.updatedAt .. SEPARATOR .. self.quote;
end

-- Transform a string to a Quote object
--
-- @param string message: serialized quote
-- @return Quote
function Quote:Unpack(message)
    local segments = string.gmatch(message, "([^("..SEPARATOR..")]+)");
    local data = {};
    for s in segments do
        table.insert(data, s);
    end

    if table.getn(data) == 6 then
        self.id = tonumber(data[1]);
        self.source = data[2];
        self.addedBy = data[3];
        self.createdAt = tonumber(data[4]);
        self.updatedAt = tonumber(data[5]);
        self.quote = data[6];
    end
end

-- Print the quote, should be used as debugging tool only
function Quote:Print(data)
    data = data or self;
    GuildMemes:Print(data.source .." (on ".. data.createdAt .."): ".. data.quote);
end

GuildMemes.Quote = Quote;