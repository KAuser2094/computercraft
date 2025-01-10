--- Based off: https://gitlab.com/ralphgod3/cctutorials/-/blob/master/Modules/Logger.lua?ref_type=heads

--- TODO:
--- Make a "global" in the returned table that is a class that changes global default values which are used when Logger.new() is ran with no params
--- Make a "singleton" that will cache its instance that modules may use.
--- Make a way to "discard" certain levels (usually Fatal)
--- Add a hook into "error" and log the stack trace before it errors out

local p = require "cc.pretty"
local colours = _G.colours
local fs = _G.fs

local TIME_FMT = "%F %T "

--- @class Logger.LoggerLevel
--- @field prefix string The prefix for the log level.
--- @field colour ccTweaked.colours.colour The color associated with the log level.
--- @field severity integer The severity level.

local DebugLevel = {
    None = { prefix = "", colour = colours.black, severity = -1}, --- @type Logger.LoggerLevel
    Temporary = {prefix = "[TMP]", colour = colours.purple, severity = 0}, --- @type Logger.LoggerLevel
    Fatal = {prefix = "[FTL]", colour = colours.red, severity = 1}, --- @type Logger.LoggerLevel
    Error = {prefix = "[ERR]", colour = colours.red, severity = 2}, --- @type Logger.LoggerLevel
    Warning = {prefix = "[WRN]", colour = colours.yellow, severity = 3}, --- @type Logger.LoggerLevel
    Info = {prefix = "[INF]", colour = colours.green, severity = 4}, --- @type Logger.LoggerLevel
    Debug = {prefix = "[DBG]", colour = colours.blue, severity = 5}, --- @type Logger.LoggerLevel
    Verbose = {prefix = "[VRB]", colour = colours.cyan, severity = 6}, --- @type Logger.LoggerLevel
}

--- @class Logger.new.kwargs The form the table passed into "new" should be when creating a new logger instance
--- @field path? string Path of the log file, defaults to "./log.txt"
--- @field globalLevel? Logger.LoggerLevel Level to default any tags to, default global level is verbose (AKA log all)
--- @field logsToKeep? integer Amount of logs to store before deleting the oldest
--- @field outputTerminal? ccTweaked.term.Redirect Terminal to print to. Default just won't print

--- Creates an instance of the logger
--- @param kwargs? Logger.new.kwargs Table with key-value pairs defined by the type
--- @return Logger LoggerInstance A new logger instance
local function new(kwargs)
    kwargs = kwargs or {} -- nil check
    local path = kwargs.path or "/log.txt"
    local globalLevel = kwargs.globalLevel or DebugLevel.Verbose
    local logsToKeep = kwargs.logsToKeep or 300
    local outputTerminal = kwargs.outputTerminal

    --- @class Logger.Log
    --- @field level Logger.LoggerLevel
    --- @field doc ccTweaked.cc.pretty.Doc

    --- @type Logger.Log[]
    Logs = {}


    --- @class Logger
    local this = {}

    --- @type table<string, Logger.LoggerLevel>
    this.Tags = {}

    this.Levels = DebugLevel

    --- Sets path to log file
    --- @param _path filePath
    --- @return Logger self For chaining
    function this.setPath(_path)
        path = _path
        return this
    end

    --- Sets Global Level
    --- @param level Logger.LoggerLevel
    --- @return Logger  self For chaining
    function this.setGlobalLevel(level)
        globalLevel = level
        return this
    end

    --- Sets the amount of logs to keep
    --- @param _logsToKeep integer
    --- @return Logger  self For chaining
    function this.setLogsToKeep(_logsToKeep)
        logsToKeep = _logsToKeep
        return this
    end

    --- Sets the output terminal
    --- @param terminal ccTweaked.term.Redirect
    --- @return Logger self For chaining
    function this.setOutputTerminal(terminal)
        outputTerminal = terminal
        return this
    end

    --- Sets the tag to the passed in leve
    --- @param tag string to change level
    --- @param level Logger.LoggerLevel Level to change to
    --- @return Logger self For chaining
    function this.setTagLevel(tag, level)
        this.Tags[tag] = level
        return this
    end

    this.setTagLevel("", DebugLevel.Verbose) -- Anything logged with no tag should always print.

    --- Writes everything in "Logs" to the log file defined by path
    local function addToLogFile()
        local file = fs.open(path, "w")
        if file then
            for _, Log in pairs(Logs) do
                file.write(p.render(Log.doc) .. "\n")
            end
            file.close()
        end
    end

    --- Uses cc.pretty to build up a string
    --- @param ... any Anything you wish to log
    --- @return ccTweaked.cc.pretty.Doc
    local function buildLogDoc(...)
        --- @type any
        local args = {...}
        --- @type ccTweaked.cc.pretty.Doc[]
        local docs = {}
        for _, arg in ipairs(args) do
            table.insert(docs, p.pretty(arg))
            table.insert(docs, p.space_line)
        end

        table.remove(docs) -- Remove the trailing space

        return p.concat(table.unpack(docs))
    end

    --- Builds the starting section of the print statemnt
    --- @param tag string
    --- @param level Logger.LoggerLevel
    --- @return ccTweaked.cc.pretty.Doc prefixDoc
    local function buildLogPrefix(tag, level)
        local stamp = os.date(TIME_FMT)
        return p.text(stamp .. " " .. level.prefix .. ":" .. tag, level.colour)
    end

    --- Logs at the given level according to the given tag
    --- @param tag string The tag which we are logging to
    --- @param level Logger.LoggerLevel The level to log at
    --- @param ... any Anything you wish to log
    local function log(tag, level, ...)
        if not this.Tags[tag] then this.setTagLevel(tag, globalLevel) end

        if level.severity <= this.Tags[tag].severity then
            local logDoc = buildLogDoc(...)
            local prefix = buildLogPrefix(tag, level)
            local fullDoc = p.concat(prefix, p.space, logDoc)
            local flattenedDoc = p.group(fullDoc)
            if outputTerminal then
                p.print(flattenedDoc)
            end

            --- @type Logger.Log
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

    --- Logs with no tag. (Technically setting tag to "" and level to Temporary)
    --- @param ... any Anything to log
    function this.logNoTag(...)
        log("", DebugLevel.Temporary, ...)
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

    return this
end

return setmetatable(
{
    new = new
},
{__call = function (_,...)
        new(...)
    end
}
)
