
local addonName, GuildMemes = ...;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true);


-- handle pull messages
function GuildMemes:HandlePlayerJoinedGroup(playerName)
    -- if the pull option is off, don't even go further
    if false == GuildMemes.Database:GetOption("quote_on_player_join_group") then
        return;
    end

    -- if the player that joined is the current player
    if GuildMemes.CURRENT_PLAYER == playerName then
        return;
    end

    local quote = GuildMemes.Database:FindRandom(playerName);

    if nil ~= quote then
        local message = string.sub(L["QUOTE_FORMAT"](quote.source, quote.quote), 0, 255);
        local destination = "PARTY";
        if true == IsInRaid() then
            destination = "RAID";
        end
        SendChatMessage(message, destination);
    end
end