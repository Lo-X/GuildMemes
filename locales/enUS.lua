
local addonName, addon = ...;
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true);

if L then
    L["ADDON_NAME"] = addonName;
    L["ADDON_DESCRIPTION"] = "Save and share your guildmates best quotes!";
    L["ADDON_VERSION"] = "Version:";
    L["ADDON_AUTHOR"] = "Author:";
    L["ADDON_MOTD"] = "Hey, thanks for using "..addonName.."! Type |cffffd700/gm|r or |cffffd700/guildmemes|r for options and |cffffd700/gm add|r for the quotes window.";
    L["QUOTE_ADDED"] = function(author, quote) return "Added quote from ".. author ..": ".. quote; end
    L["QUOTES_RESET"] = "All saved quotes have ben reset.";
    L["TAB_QUOTES"] = "Guildmates quotes";
    L["TAB_SYNC"] = "Sync quotes";
    L["TAB_ABOUT"] = "About";
    L["HEADER_NEW_QUOTE"] = "New quote";
    L["HEADER_QUOTE_LIST"] = "Saved quotes";
    L["LABEL_AUTHOR"] = "Author:";
    L["LABEL_QUOTE"] = "Quote:";
    L["LABEL_ADD_QUOTE_BUTTON"] = "Add";
    L["LABEL_SYNC_BUTTON"] = "Fetch quotes from guild";
    L["LABEL_SYNC_ONGOING_BUTTON"] = "Fetching...";
    L["LABEL_DELETE_QUOTE_BUTTON"] = "Delete";
    L["LABEL_ACTIONS_OPTIONS"] = "Actions";
    L["LABEL_SYNC_OPTIONS"] = "Synchronization";
    L["LABEL_ACTION_OPEN_QUOTES"] = "Edit quotes";
    L["LABEL_ACTION_OPEN_QUOTES_DESCRIPTION"] = "Add new quotes, edit old ones and remove those you don't want.";
    L["LABEL_ACTION_OPEN_SYNC"] = "Sync quotes";
    L["LABEL_ACTION_OPEN_SYNC_DESCRIPTION"] = "Manually fetch quotes from your guild if your guildmates have GuildMeme installed.";
    L["LABEL_ACTION_RESET_DATABASE"] = "Reset quote database";
    L["LABEL_ACTION_RESET_DATABASE_DESCRIPTION"] = "This will erase all your saved quotes! If auto sync is enabled you will receive quotes from your guildmates at login if they have GuildMeme installed.";
    L["LABEL_ACTION_RESET_DATABASE_CONFIRM"] = "This will erase all your saved quotes! Are you sure?";
    L["LABEL_OPTION_AUTO_SYNC"] = "Sync quotes automatically";
    L["LABEL_OPTION_AUTO_SYNC_DESCRIPTION"] = "Synchronize guildmates database automatically at login and automatically add newly created quotes when your guildmates create them."
    L["ERROR_NOT_IN_GUILD"] = "You can only use this addon if you have a guild!";
end