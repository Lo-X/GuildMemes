
local addonName, addon = ...;
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true);

if L then
    L["ADDON_NAME"] = addonName;
    L["QUOTE_ADDED"] = function(author, quote) return "Added quote from ".. author ..": ".. quote; end
    L["QUOTES_RESET"] = "All saved quotes have ben reset.";
    L["TAB_QUOTES"] = "Guildmates quotes";
    L["TAB_DATABASE"] = "Database and sync";
    L["TAB_ABOUT"] = "About";
    L["HEADER_NEW_QUOTE"] = "New quote";
    L["HEADER_QUOTE_LIST"] = "Saved quotes";
    L["LABEL_AUTHOR"] = "Author:";
    L["LABEL_QUOTE"] = "Quote:";
    L["LABEL_ADD_QUOTE_BUTTON"] = "Add";
    L["ERROR_NOT_IN_GUILD"] = "You can only use this addon if you have a guild!";
end