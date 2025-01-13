--- Based off: https://gitlab.com/ralphgod3/cctutorials/-/blob/master/Modules/Logger.lua?ref_type=heads

--- TODO:
--- Make a "forceLevel" that is default nil, if set then it forces level to only be upto the forceLevel even if the tag's severity is higher
--- Make a way to "discard" certain levels (usually Fatal)
--- Add a hook into "error" and log the stack trace before it errors out

local p = require "cc.pretty"
local colours = _G.colours
local fs = _G.fs

local TIME_FMT = "%F %T "

--- @class _L_ogger.LoggerLevel
--- @field prefix string The prefix for the log level.
--- @field colour ccTweaked.colours.colour The color associated with the log level.
--- @field severity integer The severity level.

local DebugLevel = {
    None = { prefix = "", colour = colours.black, severity = -1}, --- @type _L_ogger.LoggerLevel
    Temporary = {prefix = "[TMP]", colour = colours.purple, severity = 0}, --- @type _L_ogger.LoggerLevel
    Fatal = {prefix = "[FTL]", colour = colours.red, severity = 1}, --- @type _L_ogger.LoggerLevel
    Error = {prefix = "[ERR]", colour = colours.red, severity = 2}, --- @type _L_ogger.LoggerLevel
    Warning = {prefix = "[WRN]", colour = colours.yellow, severity = 3}, --- @type _L_ogger.LoggerLevel
    Info = {prefix = "[INF]", colour = colours.green, severity = 4}, --- @type _L_ogger.LoggerLevel
    Debug = {prefix = "[DBG]", colour = colours.blue, severity = 5}, --- @type _L_ogger.LoggerLevel
    Verbose = {prefix = "[VRB]", colour = colours.cyan, severity = 6}, --- @type _L_ogger.LoggerLevel
}

--- @class _L_ogger.new.kwargs The form the table passed into "new" should be when creating a new logger instance
--- @field path? string Path of the log file, defaults to "./log.txt"
--- @field level? _L_ogger.LoggerLevel Level to default any tags to, default global level is verbose (AKA log all)
--- @field logsToKeep? integer Amount of logs to store before deleting the oldest
--- @field outputTerminal? ccTweaked.term.Redirect Terminal to print to. Default just won't print
--- @field flattenPrintOut? boolean

--- Creates an instance of the logger
--- @param kwargs? _L_ogger.new.kwargs Table with key-value pairs defined by the type
--- @return common.Logger LoggerInstance A new logger instance
local function new(kwargs)
    kwargs = kwargs or {} -- nil check

    --- @type integer
    local logsToKeep = kwargs.logsToKeep or 300

    --- @class _L_ogger.settings
    local settings = {
        path = kwargs.path or "/log.txt", --- @type filePath
        level = kwargs.level or DebugLevel.Verbose, --- @type _L_ogger.LoggerLevel
        outputTerminal = kwargs.outputTerminal, --- @type ccTweaked.term.Redirect?
        flattenPrintOut = kwargs.flattenPrintOut or false, --- @type boolean
    }

    --- @param _path filePath
    --- @return _L_ogger.settings self -- Chaining
    function settings:setPath(_path)
        self.path = _path
        return self
    end

    --- @param _level _L_ogger.LoggerLevel
    --- @return _L_ogger.settings self -- Chaining
    function settings:setLevel(_level)
        self.level = _level
        return self
    end

    --- @param _outputTerminal? ccTweaked.term.Redirect
    --- @return _L_ogger.settings self -- Chaining
    function settings:setOutputTerminal(_outputTerminal)
        self.outputTerminal = _outputTerminal
        return self
    end

    --- @return self -- Chaining
    function settings:removeTerminal()
        self.outputTerminal = nil
        return self
    end

    --- @param _flattenPrintOut boolean
    --- @return _L_ogger.settings self -- Chaining
    function settings:setFlattenPrintOut(_flattenPrintOut)
        self.flattenPrintOut = _flattenPrintOut
        return self
    end

    --- @return _L_ogger.settings copy
    function settings:getCopy()
        local function deepCopy(tbl)
            local copy = {}
            for k,v in pairs(tbl) do
                if type(v) == "table" then
                    copy[k] = deepCopy(v)
                else
                    copy[k] = v
                end
            end
            return copy
        end
        return deepCopy(self)
    end

    --- @class _L_ogger.Log
    --- @field level _L_ogger.LoggerLevel
    --- @field doc ccTweaked.cc.pretty.Doc

    --- @type _L_ogger.Log[]
    Logs = {}


    --- @class common.Logger
    local this = {}

    --- @type table<string, _L_ogger.settings>
    this.TagSettings = {}

    this.Levels = DebugLevel

    --[[
        GLOBAL SETTINGS
    ]]

    --- Sets the amount of logs to keep (Note this is only a global setting, tags all share the same global log count)
    --- @param _logsToKeep integer
    --- @return common.Logger  self For chaining
    function this.setLogsToKeep(_logsToKeep)
        logsToKeep = _logsToKeep
        return this
    end

    --- Sets Global Level
    --- @param level _L_ogger.LoggerLevel
    --- @return common.Logger  self For chaining
    function this.setGlobalLevel(level)
        settings.level = level
        return this
    end

    --- Sets path to log file
    --- @param _path filePath
    --- @return common.Logger self For chaining
    function this.setGlobalPath(_path)
        settings.path = _path
        return this
    end

    --- Sets the output terminal
    --- @param terminal? ccTweaked.term.Redirect
    --- @return common.Logger self For chaining
    function this.setGlobalOutputTerminal(terminal)
        settings.outputTerminal = terminal
        return this
    end

    -- Returns the outputTerminal (if any)
    --- @return ccTweaked.term.Redirect? outputTerminal
    function this.getGlobalOutputTerminal()
        return settings.outputTerminal
    end

    --- @param bool boolean Whether to flatten out when logging out to terminal
    --- @return common.Logger self For chaining
    function this.setGlobalFlattenPrintOut(bool)
        settings.flattenPrintOut = bool
        return this
    end

    --[[
        TAG SETTINGS
    ]]

    --- Sets the tag to the passed in settings
    --- @param tag string
    --- @param _setting _L_ogger.settings Level to change to
    --- @return common.Logger self For chaining
    function this.setTagSettings(tag, _setting)
        this.TagSettings[tag] = _setting
        return this
    end

    --- Gets the settings of the passed in tag (will be set to global settings if not previously set)
    --- @param tag string
    --- @return _L_ogger.settings tagSetting
    function this.getTagSettings(tag)
        if not this.TagSettings[tag] then this.setTagSettings(tag, settings:getCopy()) end
        return this.TagSettings[tag]
    end

    --- Sets the tag to the passed in level
    --- @param tag string to change level
    --- @param level _L_ogger.LoggerLevel Level to change to
    --- @return common.Logger self For chaining
    function this.setTagLevel(tag, level)
        this.getTagSettings(tag).level = level
        return this
    end
    this.setTagLevel("", DebugLevel.Verbose) -- Anything logged with no tag should always print.

    --- Gets the level of the passed in tag (will be set to global settings if not previously set)
    --- @param tag string
    --- @return _L_ogger.LoggerLevel tagLevel
    function this.getTagLevel(tag)
        return this.getTagSettings(tag).level
    end

    --- Sets path to log file
    --- @param tag string
    --- @param _path filePath
    --- @return common.Logger self For chaining
    function this.setTagPath(tag, _path)
        this.getTagSettings(tag).path = _path
        return this
    end

    --- Sets the output terminal
    --- @param tag string
    --- @param terminal? ccTweaked.term.Redirect
    --- @return common.Logger self For chaining
    function this.setTagOutputTerminal(tag, terminal)
        this.getTagSettings(tag).outputTerminal = terminal
        return this
    end

    --- Returns the outputTerminal (if any)
    --- @param tag string
    --- @return ccTweaked.term.Redirect? outputTerminal
    function this.getTagOutputTerminal(tag)
        return this.getTagSettings(tag).outputTerminal
    end

    --- @param tag string
    --- @param bool boolean Whether to flatten out when logging out to terminal
    --- @return common.Logger self For chaining
    function this.setTagFlattenPrintOut(tag, bool)
        this.getTagSettings(tag).flattenPrintOut = bool
        return this
    end

    --[[
        ACTUAL LOG
    ]]

    --- Writes everything in "Logs" to the log file defined by path
    local function addToLogFile()
        local file = fs.open(settings.path, "w")
        if file then
            for _, Log in pairs(Logs) do
                file.write(p.render(Log.doc) .. "\n")
            end
            file.close()
        end
    end

    --- Uses cc.pretty to build up a doc
    --- @param ... any Anything you wish to log
    --- @return ccTweaked.cc.pretty.Doc
    local function buildLogDoc(...)
        --- @type any
        local args = {...}
        --- @type ccTweaked.cc.pretty.Doc[]
        local docs = {}
        local count = select("#", ...)
        for i=1, count do
            local a = args[i]
            table.insert(docs, p.pretty(a))
            table.insert(docs, p.space_line)
        end

        table.remove(docs) -- Remove the trailing space

        return p.concat(table.unpack(docs))
    end

    --- Uses cc.pretty to build up a string
    --- @param ... any Anything you wish to become a pretty string
    function this.buildString(...)
        local doc = buildLogDoc(...)
        return p.render(p.group(doc))
    end

    --- Uses cc.pretty to print (Note this isn't a log, it just an alternate way to print)
    --- @param ... any Anything you wish to print
    function this.print(...)
        local doc = buildLogDoc(...)
        p.print(doc)
    end

    --- Builds the starting section of the print statemnt
    --- @param tag string
    --- @param level _L_ogger.LoggerLevel
    --- @return ccTweaked.cc.pretty.Doc prefixDoc
    local function buildLogPrefix(tag, level)
        local stamp = os.date(TIME_FMT)
        return p.text(stamp .. " " .. level.prefix .. ":" .. tag, level.colour)
    end

    --- Logs at the given level according to the given tag
    --- @param tag string The tag which we are logging to
    --- @param level _L_ogger.LoggerLevel The level to log at
    --- @param ... any Anything you wish to log
    local function log(tag, level, ...)
        local tagSettings = this.getTagSettings(tag)
        local tagLevel = this.getTagLevel(tag)

        if level.severity <= tagLevel.severity then
            local logDoc = buildLogDoc(...)
            local prefix = buildLogPrefix(tag, level)
            local fullDoc = p.concat(prefix, p.space, logDoc)
            local flattenedDoc = p.group(fullDoc)
            if tagSettings.outputTerminal then
                -- TODO: Make this acutally use outputTerminal. Right now just goes straight to term.current() (I think?)
                p.print(tagSettings.flattenPrintOut and flattenedDoc or fullDoc)
            end

            --- @type _L_ogger.Log
            local Log = {
                level = level,
                doc = flattenedDoc
            }
            table.insert(Logs, Log)
            addToLogFile()
            while #Logs > logsToKeep do
                table.remove(Logs,1)
            end
        end

    end

    --[[ For easier veiwing
    None = { prefix = "", colour = colours.black, severity = -1}, --- @type Logger.LoggerLevel
    Temporary = {prefix = "[TMP]", colour = colours.purple, severity = 0}, --- @type Logger.LoggerLevel
    Fatal = {prefix = "[FTL]", colour = colours.red, severity = 1}, --- @type Logger.LoggerLevel
    Error = {prefix = "[ERR]", colour = colours.red, severity = 2}, --- @type Logger.LoggerLevel
    Warning = {prefix = "[WRN]", colour = colours.yellow, severity = 3}, --- @type Logger.LoggerLevel
    Info = {prefix = "[INF]", colour = colours.green, severity = 4}, --- @type Logger.LoggerLevel
    Debug = {prefix = "[DBG]", colour = colours.blue, severity = 5}, --- @type Logger.LoggerLevel
    Verbose = {prefix = "[VRB]", colour = colours.cyan, severity = 6}, --- @type Logger.LoggerLevel
    --]]

    --- Logs with no tag. (Technically setting tag to "" and level to Temporary), Note: this log specifically makes sure to always print to `term.current()`
    --- @param ... any Anything to log
    function this.logNoTag(...)
        local oldTerm = this.getTagOutputTerminal("")
        this.setTagOutputTerminal("", term.current())
        log("", DebugLevel.Temporary, ...)
        this.setTagOutputTerminal("", oldTerm)
    end

    --- Attempts to Log Temporary
    --- @param tag string The tag we are debugging to
    --- @param ... any Anything to log
    function this.logT(tag, ...)
        log(tag, DebugLevel.Temporary, ...)
    end

    --- Attempts to Log Fatal
    --- @param tag string The tag we are debugging to
    --- @param ... any Anything to log
    function this.logF(tag, ...)
        log(tag, DebugLevel.Fatal, ...)
    end

    --- Attempts to Log Error
    --- @param tag string The tag we are debugging to
    --- @param ... any Anything to log
    function this.logE(tag, ...)
        log(tag, DebugLevel.Error, ...)
    end

    --- Attempts to Log Warning
    --- @param tag string The tag we are debugging to
    --- @param ... any Anything to log
    function this.logW(tag, ...)
        log(tag, DebugLevel.Warning, ...)
    end

    --- Attempts to Log Info
    --- @param tag string The tag we are debugging to
    --- @param ... any Anything to log
    function this.logI(tag, ...)
        log(tag, DebugLevel.Info, ...)
    end

    --- Attempts to Log Debig
    --- @param tag string The tag we are debugging to
    --- @param ... any Anything to log
    function this.logD(tag, ...)
        log(tag, DebugLevel.Debug, ...)
    end

    --- Attempts to Log Verbose
    --- @param tag string The tag we are debugging to
    --- @param ... any Anything to log
    function this.logV(tag, ...)
        log(tag, DebugLevel.Verbose, ...)
    end

    --[[
        CUSTOM ERROR
    ]]

    --- Errors the program at the given level, printing out the message (and usually some info of error location before it). Will also log a Fatal level log at NoTag.
    --- @param message? any
    --- @param level? integer
    function this.error(message, level) -- errorNoTag
        level = level and level + 1 or level -- Increase level if it was given

        this.errorWithTag("", message, level)
    end

    --- Errors the program at the given level, printing out the message (and usually some info of error location before it). Will also log a Fatal level log at the given tag.
    --- @param tag string
    --- @param message? any
    --- @param level? integer
    function this.errorWithTag(tag, message, level)
        level = level and level + 1 or level -- Increase level if it was given

        local trace = debug.traceback()
        local logMsg = p.render(p.concat(p.pretty(trace), p.space_line, p.pretty(message), p.line))
        this.logF(tag, logMsg)

        error(message, level)
    end

    --[[
        CUSTOM ASSERT
    ]]

    --- Asserts that `v` is truthy and if so returns ALL arguments, otherwise assertion error and displays the `message` given.
    --- Also logs fatal if the assertion fails at NoTag
    --- @param v? any -- Why the heck is this optional? I am just following how native assert() works...
    --- @param message? any
    --- @param ...? any
    function this.assert(v, message, ...)
        return this.assertWithTag("", v, message, ...)
    end

    --- Asserts that `v` is falsy and if so returns ALL arguments, otherwise assertion error and displays the `message` given.
    --- Also logs fatal if the assertion fails at NoTag
    --- @param v? any -- Why the heck is this optional? I am just following how native assert() works...
    --- @param message? any
    --- @param ...? any
    function this.assertNot(v, message, ...)
        return this.assertNotWithTag("", v, message, ...)
    end

    --- Asserts that `v` is truthy and if so returns ALL arguments EXCEPT `tag`, otherwise assertion error and displays the `message` given.
    --- Also logs fatal if the assertion fails at `tag`
    --- @param v? any -- Why the heck is this optional? I am just following how native assert() works...
    --- @param message? any
    --- @param ...? any
    function this.assertWithTag(tag, v, message, ...)
        if v then
            return assert(v, message, ...) -- Technically do not need to assert here, but in case someone is hooking into assert I will
        else
            this.logF(tag, message)
            return assert(v, message, ...)
        end
    end

    --- Asserts that `v` is falsy and if so returns ALL arguments EXCEPT `tag`, otherwise assertion error and displays the `message` given.
    --- Also logs fatal if the assertion fails at `tag`
    --- @param v? any -- Why the heck is this optional? I am just following how native assert() works...
    --- @param message? any
    --- @param ...? any
    function this.assertNotWithTag(tag, v, message, ...)
        local ret = { this.assertWithTag(tag, not v, message, ...) }
        ret[2] = v -- Turn it back into the value, not a boolean
        return ret
    end

    --- Some as `Logger.assert` but will run `fn(table.unpack(args))` and `v` is whether it does not errror.
    --- Similarly, instead of returning v it will returns all return values of the function at the front.
    --- @param fn any
    --- @param args? any[]
    --- @param message any
    --- @param ... any
    function this.assertFunctionRuns(fn, args, message, ...)
        return this.assertFunctionRunsWithTag("", fn, args, message, ...)
    end

    --- Some as `Logger.assert` but will run `fn(table.unpack(args))` and `v` is whether it DOES errror.
    --- and instead of `fn` and `args` it will return `ok` and `err` from the pcall
    --- @param fn any
    --- @param args? any[]
    --- @param message any
    --- @param ... any
    function this.assertFunctionErrors(fn, args, message, ...)
        return this.assertFunctionErrorsWithTag("", fn, args, message, ...)
    end

    --- Some as `Logger.assert` but will run `fn(table.unpack(args))` and `v` is whether it does not errror.
    --- Similarly, instead of returning v it will returns all return values of the function at the front.
    --- @param tag string
    --- @param fn any
    --- @param args? any[]
    --- @param message any
    --- @param ... any
    function this.assertFunctionRunsWithTag(tag, fn, args, message, ...)
        -- Not actually using assert here for the success case, so if someone was expecting to hook assert then RIP
        args = args or {} -- In case no arguments
        local protected = { pcall(fn, table.unpack(args)) }

        if protected[1] then -- Did not error
            table.remove(protected, 1)
            return table.unpack(protected), message, ...
        else
            local pretty_args = {} -- Note: Will end up with a space line in front
            if args then
                for _, arg in pairs(args) do
                    table.insert(pretty_args, p.space_line)
                    table.insert(pretty_args, p.pretty(arg))
                end
            end
            local fn_args_msg = p.render(p.concat(p.pretty(fn), p.space, "ran on", table.unpack(pretty_args)))

            return this.assertWithTag(tag, false and fn_args_msg, message .. "\t[ERROR]: " .. protected[2])
        end
    end

    --- Some as `Logger.assert` but will run `fn(table.unpack(args))` and `v` is whether it DOES errror.
    --- and instead of `fn` and `args` it will return `ok` and `err` from the pcall
    --- @param tag string
    --- @param fn any
    --- @param args? any[]
    --- @param message any
    --- @param ... any
    function this.assertFunctionErrorsWithTag(tag, fn, args, message, ...)
        -- Not actually using assert here for the success case, so if someone was expecting to hook assert then RIP
        args = args or {} -- In case no arguments
        local protected = { pcall(fn, table.unpack(args)) }

        if protected[1] then -- Did not error
            local pretty_args = {} -- Note: Will end up with a space line in front
            if args then
                for _, arg in pairs(args) do
                    table.insert(pretty_args, p.space_line)
                    table.insert(pretty_args, p.pretty(arg))
                end
            end
            local fn_args_msg = p.render(p.concat(p.pretty(fn), p.space, "ran on", table.unpack(pretty_args)))

            return this.assertWithTag(tag, false and fn_args_msg, message .. "\t[EXPECTED ERROR]: " .. protected[2])
        else
            return protected[1], protected[2], message, ...
        end
    end

    return this
end

return setmetatable(
{
    new = new,
    -- require SHOULD be caching this, so this will only ever be a single instance
    singleton = new().setGlobalOutputTerminal(nil).setGlobalLevel(DebugLevel.Verbose).setLogsToKeep(300).setGlobalPath("/log/program/" .. (arg and arg[0] .. ".txt" or "unkown_script_name.txt"))
},
{__call = function (_,...)
        new(...)
    end
}
)
