
local addonName, addon = ...;
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "frFR", false);

if L then
    L["ADDON_NAME"] = addonName;
    L["DATE_FORMAT"] = "%d/%m/%y";
end