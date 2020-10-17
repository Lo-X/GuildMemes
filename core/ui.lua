
local addonName, GuildMemes = ...;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true);
local setmetatable = _G.setmetatable;

local AceGUI = LibStub("AceGUI-3.0");
local isOpened = false;

local TAB_QUOTES = "TAB_QUOTES";
local TAB_DATABASE = "TAB_DATABASE";
local TAB_ABOUT = "TAB_ABOUT";

-- Add quote form object
local AddQuoteForm = {
    authorValue = "",
    quoteValue = "",
    button = nil,
};
AddQuoteForm.__index = AddQuoteForm;

function AddQuoteForm:CheckButtonEnable()
    if "" ~= self.authorValue and "" ~= self.quoteValue then
        self.button:SetDisabled(false);
    else
        self.button:SetDisabled(true);
    end
end

local function AddQuoteLines(quote, container)
    local lineGroup = AceGUI:Create("SimpleGroup");
    lineGroup:SetFullWidth(true);
    lineGroup:SetLayout("Flow");
    container:AddChild(lineGroup);

    local authorEdit = AceGUI:Create("EditBox");
    authorEdit:SetLabel("Author:");
    authorEdit:SetRelativeWidth(0.2);
    authorEdit:SetText(quote.source);
    authorEdit:SetCallback("OnEnterPressed", function(widget, event, text) quote.source = text end);
    lineGroup:AddChild(authorEdit);

    local quoteEdit = AceGUI:Create("EditBox");
    quoteEdit:SetLabel("Quote:");
    quoteEdit:SetRelativeWidth(0.8);
    quoteEdit:SetText(quote.quote);
    quoteEdit:SetCallback("OnEnterPressed", function(widget, event, text) quote.quote = text end);
    lineGroup:AddChild(quoteEdit);
end

-- fills the quotes tab with quotes and form to add a new one
local function FillTabQuotes(container)
    local quoteForm = {};
    setmetatable(quoteForm, AddQuoteForm);

    local tabGroup = AceGUI:Create("SimpleGroup");
    tabGroup:SetFullWidth(true);
    tabGroup:SetFullHeight(true);
    tabGroup:SetLayout("Flow");

        local addHeading = AceGUI:Create("Heading");
        addHeading:SetText("New quote:");
        addHeading:SetFullWidth(true);
        tabGroup:AddChild(addHeading);

        local addFormGroup = AceGUI:Create("SimpleGroup");
        addFormGroup:SetFullWidth(true);
        addFormGroup:SetHeight(300);
        addFormGroup:SetLayout("Flow");
        tabGroup:AddChild(addFormGroup);

            local authorEdit = AceGUI:Create("EditBox");
            authorEdit:SetLabel("Author:");
            authorEdit:SetRelativeWidth(0.2);
            authorEdit:SetCallback("OnEnterPressed", function(widget, event, text) 
                quoteForm.authorValue = text;
                quoteForm:CheckButtonEnable(); 
            end);
            addFormGroup:AddChild(authorEdit);

            local quoteEdit = AceGUI:Create("EditBox");
            quoteEdit:SetLabel("Quote:");
            quoteEdit:SetRelativeWidth(0.6);
            quoteEdit:SetCallback("OnEnterPressed", function(widget, event, text) 
                quoteForm.quoteValue = text;
                quoteForm:CheckButtonEnable();
            end);
            addFormGroup:AddChild(quoteEdit);

            local addButton = AceGUI:Create("Button");
            addButton:SetText("Add");
            addButton:SetRelativeWidth(0.2);
            addFormGroup:AddChild(addButton);
            quoteForm.button = addButton;
            quoteForm:CheckButtonEnable();


        local quotesHeading = AceGUI:Create("Heading");
        quotesHeading:SetText("Saved quotes:");
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

                
                local quotes = GuildMemes.Database:FindAll();
                table.foreach(quotes, function(k, quote)
                    AddQuoteLines(quote, scrollFrame);
                end);

    addButton:SetCallback("OnClick", function(widget, event, text) 
        if "" ~= quoteForm.authorValue and "" ~= quoteForm.quoteValue then
            print(table.getn(GuildMemes.Database:FindAll()));
            -- add the quote
            local quote = GuildMemes:AddQuote(quoteForm.authorValue, quoteForm.quoteValue);
            quoteForm.authorValue = "";
            quoteForm.quoteValue = "";
            authorEdit:SetText("");
            quoteEdit:SetText("");

            -- add the quote to quote list
            scrollFrame:ReleaseChildren();
            local quotes = GuildMemes.Database:FindAll();
            print(table.getn(quotes));
            table.foreach(quotes, function(k, quote)
                AddQuoteLines(quote, scrollFrame);
            end);
            scrollFrame:DoLayout();
        end
    end);

    container:AddChild(tabGroup);
end

-- fills the database tab with database and communications actions
local function FillTabDatabase(container)
    --local desc = AceGUI:Create("Label")
    --desc:SetText("This is Tab 2")
    --desc:SetFullWidth(true)
    --container:AddChild(desc)

    --local button = AceGUI:Create("Button")
    --button:SetText("Tab 2 Button")
    --button:SetWidth(200)
    --container:AddChild(button)
end

-- fills the about tab
local function FillTabAbout(container)
end

-- Callback function for OnGroupSelected
local function SelectGroup(container, event, group)
    container:ReleaseChildren();
    if TAB_QUOTES == group then
        FillTabQuotes(container);
    elseif TAB_DATABASE == group then
        FillTabDatabase(container);
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
    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget); isOpened = false; end)
    -- Fill Layout - the TabGroup widget will fill the whole frame
    frame:SetLayout("Fill")

    -- Create the TabGroup
    local tab =  AceGUI:Create("TabGroup")
    tab:SetLayout("Flow")
    -- Setup which tabs to show
    tab:SetTabs({
        {text = L[TAB_QUOTES], value = TAB_QUOTES}, 
        {text = L[TAB_DATABASE], value = TAB_DATABASE},
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