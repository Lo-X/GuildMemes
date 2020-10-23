
local addonName, GuildMemes = ...;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true);


-- handle pull messages
function GuildMemes:HandleD4Message(prefix, message, distribution, sender)
    -- if the pull option is off, don't even go further
    if false == GuildMemes.Database:GetOption("quote_on_pull") then
        return;
    end

    local data = {};
    local segments = string.gmatch(message, "([^\t]+)");
    for s in segments do
        table.insert(data, s);
    end

    if "PT" == data[1] and GuildMemes.CURRENT_PLAYER == sender then
        local quote = GuildMemes.Database:FindRandom();

        if nil ~= quote then
            local message = string.sub(L["QUOTE_FORMAT"](quote.source, quote.quote), 0, 255);
            local destination = "PARTY";
            if true == IsInRaid() then
                destination = "RAID_WARNING";
            end
            SendChatMessage(message, destination);
        end
    end
end