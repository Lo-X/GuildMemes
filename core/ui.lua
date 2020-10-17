
local addonName, GuildMemes = ...;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true);
local setmetatable = _G.setmetatable;

local AceGUI = LibStub("AceGUI-3.0");
local isOpened = false;
GuildMemes.syncTimer = nil;

local TAB_QUOTES = "TAB_QUOTES";
local TAB_SYNC = "TAB_SYNC";
local TAB_ABOUT = "TAB_ABOUT";

-- Add quote form object
local GuildMemeUI = {
    authorValue = "",
    quoteValue = "",
    button = nil,
};
GuildMemeUI.__index = GuildMemeUI;

--------------------------------------------------------------------------------------------------------------------------------------------------------------

function GuildMemeUI:CheckButtonEnable()
    if "" ~= self.authorValue and "" ~= self.quoteValue then
        self.button:SetDisabled(false);
    else
        self.button:SetDisabled(true);
    end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- refreshes the quote list display
function GuildMemeUI:RefreshQuoteList(container)
    container:ReleaseChildren();
    local quotes = GuildMemes.Database:FindAll();
    table.foreach(quotes, function(k, quote)
        GuildMemeUI:AddQuoteLine(quote, container);
    end);
    container:DoLayout();
end

-- adds a quote in the quote list with edition fields and buttons
function GuildMemeUI:AddQuoteLine(quote, container)
    local lineGroup = AceGUI:Create("SimpleGroup");
    lineGroup:SetFullWidth(true);
    lineGroup:SetLayout("Flow");
    container:AddChild(lineGroup);

    local authorEdit = AceGUI:Create("EditBox");
    authorEdit:SetLabel(L["LABEL_AUTHOR"]);
    authorEdit:SetRelativeWidth(0.2);
    authorEdit:SetText(quote.source);
    authorEdit:SetCallback("OnEnterPressed", function(widget, event, text) quote.source = text end);
    lineGroup:AddChild(authorEdit);

    local quoteEdit = AceGUI:Create("EditBox");
    quoteEdit:SetLabel(L["LABEL_QUOTE"]);
    quoteEdit:SetRelativeWidth(0.67);
    quoteEdit:SetText(quote.quote);
    quoteEdit:SetCallback("OnEnterPressed", function(widget, event, text) quote.quote = text end);
    lineGroup:AddChild(quoteEdit);

    local deleteButton = AceGUI:Create("Button");
    deleteButton:SetText(L["LABEL_DELETE_QUOTE_BUTTON"]);
    deleteButton:SetRelativeWidth(0.12);
    deleteButton:SetCallback("OnClick", function(widget, event, text) GuildMemes.Database:Remove(quote); GuildMemeUI:RefreshQuoteList(container); end);
    lineGroup:AddChild(deleteButton);
end

-- refreshes the waiting list display
function GuildMemeUI:RefreshWaitingList(container)
    container:ReleaseChildren();
    table.foreach(GuildMemes.WaitingList:FindAll(), function(k, quote)
        GuildMemeUI:AddWaitingListLine(quote, container);
    end);
    container:DoLayout();
end
function GuildMemes:RefreshWaitingList(container) GuildMemeUI:RefreshWaitingList(container); end

-- adds a waiting quote line in container
function GuildMemeUI:AddWaitingListLine(quote, container)
    local lineGroup = AceGUI:Create("InlineGroup");
    lineGroup:SetFullWidth(true);
    lineGroup:SetLayout("Flow");
    container:AddChild(lineGroup);

    local authorLabel = AceGUI:Create("Label");
    authorLabel:SetRelativeWidth(0.2);
    authorLabel:SetText(quote.source);
    lineGroup:AddChild(authorLabel);

    local quoteLabel = AceGUI:Create("Label");
    quoteLabel:SetRelativeWidth(0.67);
    quoteLabel:SetText(quote.quote);
    lineGroup:AddChild(quoteLabel);

    local addButton = AceGUI:Create("Button");
    addButton:SetText(L["LABEL_ADD_QUOTE_BUTTON"]);
    addButton:SetRelativeWidth(0.12);
    addButton:SetCallback("OnClick", function(widget, event, text)
        GuildMemes.Database:Save(quote);
        GuildMemes.WaitingList:Remove(quote);
        GuildMemeUI:RefreshWaitingList(container);
    end);
    lineGroup:AddChild(addButton);
end


--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- fills the quotes tab with quotes and form to add a new one
local function FillTabQuotes(container)
    local quoteForm = {};
    setmetatable(quoteForm, GuildMemeUI);

    local tabGroup = AceGUI:Create("SimpleGroup");
    tabGroup:SetFullWidth(true);
    tabGroup:SetFullHeight(true);
    tabGroup:SetLayout("Flow");

        local addHeading = AceGUI:Create("Heading");
        addHeading:SetText(L["HEADER_NEW_QUOTE"]);
        addHeading:SetFullWidth(true);
        tabGroup:AddChild(addHeading);

        local addFormGroup = AceGUI:Create("SimpleGroup");
        addFormGroup:SetFullWidth(true);
        addFormGroup:SetHeight(75);
        addFormGroup:SetLayout("Flow");
        tabGroup:AddChild(addFormGroup);

            local authorEdit = AceGUI:Create("EditBox");
            authorEdit:SetLabel(L["LABEL_AUTHOR"]);
            authorEdit:SetRelativeWidth(0.2);
            authorEdit:SetCallback("OnEnterPressed", function(widget, event, text) 
                quoteForm.authorValue = text;
                quoteForm:CheckButtonEnable(); 
            end);
            addFormGroup:AddChild(authorEdit);

            local quoteEdit = AceGUI:Create("EditBox");
            quoteEdit:SetLabel(L["LABEL_QUOTE"]);
            quoteEdit:SetRelativeWidth(0.67);
            quoteEdit:SetCallback("OnEnterPressed", function(widget, event, text) 
                quoteForm.quoteValue = text;
                quoteForm:CheckButtonEnable();
            end);
            addFormGroup:AddChild(quoteEdit);

            local addButton = AceGUI:Create("Button");
            addButton:SetText(L["LABEL_ADD_QUOTE_BUTTON"]);
            addButton:SetRelativeWidth(0.12);
            addFormGroup:AddChild(addButton);
            quoteForm.button = addButton;
            quoteForm:CheckButtonEnable();


        local quotesHeading = AceGUI:Create("Heading");
        quotesHeading:SetText(L["HEADER_QUOTE_LIST"]);
        quotesHeading:SetFullWidth(true);
        tabGroup:AddChild(quotesHeading);

        local scrollGroup = AceGUI:Create("SimpleGroup");
        scrollGroup:SetFullWidth(true);
        scrollGroup:SetFullHeight(true);
        scrollGroup:SetLayout("Fill");
        tabGroup:AddChild(scrollGroup);

            scrollFrame = AceGUI:Create("ScrollFrame");
            scrollFrame:SetLayout("Flow");
            scrollGroup:AddChild(scrollFrame);
            GuildMemeUI:RefreshQuoteList(scrollFrame);

    addButton:SetCallback("OnClick", function(widget, event, text)
        if "" ~= quoteForm.authorValue and "" ~= quoteForm.quoteValue then
            -- add the quote
            local quote = GuildMemes:AddQuote(quoteForm.authorValue, quoteForm.quoteValue);
            quoteForm.authorValue = "";
            quoteForm.quoteValue = "";
            authorEdit:SetText("");
            quoteEdit:SetText("");

            -- add the quote to quote list
            GuildMemeUI:RefreshQuoteList(scrollFrame);
        end
    end);

    container:AddChild(tabGroup);
end

-- fills the synchronization tab
local function FillTabSync(container)
    local tabGroup = AceGUI:Create("SimpleGroup");
    tabGroup:SetFullWidth(true);
    tabGroup:SetFullHeight(true);
    tabGroup:SetLayout("Flow");

        local actionGroup = AceGUI:Create("SimpleGroup");
        actionGroup:SetFullWidth(true);
        actionGroup:SetHeight(60);
        actionGroup:SetLayout("Flow");
        tabGroup:AddChild(actionGroup);

            local syncButton = AceGUI:Create("Button");
            syncButton:SetText(L["LABEL_SYNC_BUTTON"]);
            syncButton:SetRelativeWidth(0.5);
            actionGroup:AddChild(syncButton);


        local scrollGroup = AceGUI:Create("SimpleGroup");
        scrollGroup:SetFullWidth(true);
        scrollGroup:SetFullHeight(true);
        scrollGroup:SetLayout("Fill");
        tabGroup:AddChild(scrollGroup);

            scrollFrame = AceGUI:Create("ScrollFrame");
            scrollFrame:SetLayout("Flow");
            scrollGroup:AddChild(scrollFrame);
            GuildMemeUI:RefreshWaitingList(scrollFrame);

    syncButton:SetCallback("OnClick", function(widget, event, text)
        GuildMemes:AskQuoteList(); 
        GuildMemes.syncTimer = GuildMemes:ScheduleRepeatingTimer("RefreshWaitingList", 2, scrollFrame);
        syncButton:SetText(L["LABEL_SYNC_ONGOING_BUTTON"]);
        syncButton:SetDisabled(true);
    end)

    container:AddChild(tabGroup);
end

-- fills the about tab
local function FillTabAbout(container)
end

-- Callback function for OnGroupSelected
local function SelectGroup(container, event, group)
    if nil ~= GuildMemes.syncTimer then
        GuildMemes:CancelTimer(GuildMemes.syncTimer);
    end
    container:ReleaseChildren();
    if TAB_QUOTES == group then
        FillTabQuotes(container);
    elseif TAB_SYNC == group then
        FillTabSync(container);
    elseif TAB_ABOUT == group then
        FillTabAbout(container);
    end
end

function GuildMemes:OpenUI()
    -- Don't ipen multiple windows
    if isOpened then return end

    local frame = AceGUI:Create("Frame")
    frame:SetTitle(addonName);
    --frame:SetStatusText("AceGUI-3.0 Example Container Frame")
    frame:SetCallback("OnClose", function(widget)
        if nil ~= GuildMemes.syncTimer then
            GuildMemes:CancelTimer(GuildMemes.syncTimer);
        end
        AceGUI:Release(widget);
        isOpened = false;
    end)
    -- Fill Layout - the TabGroup widget will fill the whole frame
    frame:SetLayout("Fill")

    -- Create the TabGroup
    local tab =  AceGUI:Create("TabGroup")
    tab:SetLayout("Flow")
    -- Setup which tabs to show
    tab:SetTabs({
        {text = L[TAB_QUOTES], value = TAB_QUOTES}, 
        {text = L[TAB_SYNC], value = TAB_SYNC},
        {text = L[TAB_ABOUT], value = TAB_ABOUT},
    })
    -- Register callback
    tab:SetCallback("OnGroupSelected", SelectGroup)
    -- Set initial Tab (this will fire the OnGroupSelected callback)
    tab:SelectTab(TAB_QUOTES)

    -- add to the frame container
    frame:AddChild(tab)

    isOpened = true;
end