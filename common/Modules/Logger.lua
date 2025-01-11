--- Based off: https://gitlab.com/ralphgod3/cctutorials/-/blob/master/Modules/Logger.lua?ref_type=heads

--- TODO:
--- Make a "forceLevel" that is default nil, if set then it forces level to only be upto the forceLevel even if the tag's severity is higher
--- Make a "singleton" that will cache its instance that modules may use.
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
--- @field globalLevel? _L_ogger.LoggerLevel Level to default any tags to, default global level is verbose (AKA log all)
--- @field logsToKeep? integer Amount of logs to store before deleting the oldest
--- @field outputTerminal? ccTweaked.term.Redirect Terminal to print to. Default just won't print

--- Creates an instance of the logger
--- @param kwargs? _L_ogger.new.kwargs Table with key-value pairs defined by the type
--- @return common.Logger LoggerInstance A new logger instance
local function new(kwargs)
    kwargs = kwargs or {} -- nil check
    local path = kwargs.path or "/log.txt"
    local globalLevel = kwargs.globalLevel or DebugLevel.Verbose
    local logsToKeep = kwargs.logsToKeep or 300
    local outputTerminal = kwargs.outputTerminal
    local flattenPrintOut = false

    --- @class _L_ogger.Log
    --- @field level _L_ogger.LoggerLevel
    --- @field doc ccTweaked.cc.pretty.Doc

    --- @type _L_ogger.Log[]
    Logs = {}


    --- @class common.Logger
    local this = {}

    --- @type table<string, _L_ogger.LoggerLevel>
    this.Tags = {}

    this.Levels = DebugLevel

    --- Sets path to log file
    --- @param _path filePath
    --- @return common.Logger self For chaining
    function this.setPath(_path)
        path = _path
        return this
    end

    --- Sets Global Level
    --- @param level _L_ogger.LoggerLevel
    --- @return common.Logger  self For chaining
    function this.setGlobalLevel(level)
        globalLevel = level
        return this
    end

    --- Sets the amount of logs to keep
    --- @param _logsToKeep integer
    --- @return common.Logger  self For chaining
    function this.setLogsToKeep(_logsToKeep)
        logsToKeep = _logsToKeep
        return this
    end

    --- Sets the output terminal
    --- @param terminal? ccTweaked.term.Redirect
    --- @return common.Logger self For chaining
    function this.setOutputTerminal(terminal)
        outputTerminal = terminal
        return this
    end

    -- Returns the outputTerminal (if any)
    --- @return ccTweaked.term.Redirect? outputTerminal
    function this.getOutputTerminal()
        return outputTerminal
    end

    --- Sets the tag to the passed in leve
    --- @param tag string to change level
    --- @param level _L_ogger.LoggerLevel Level to change to
    --- @return common.Logger self For chaining
    function this.setTagLevel(tag, level)
        this.Tags[tag] = level
        return this
    end

    --- @param bool boolean Whether to flatten out when logging out to terminal
    --- @return common.Logger self For chaining
    function this.setFlattenPrintOut(bool)
        flattenPrintOut = bool
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
        if not this.Tags[tag] then this.setTagLevel(tag, globalLevel) end

        if level.severity <= this.Tags[tag].severity then
            local logDoc = buildLogDoc(...)
            local prefix = buildLogPrefix(tag, level)
            local fullDoc = p.concat(prefix, p.space, logDoc)
            local flattenedDoc = p.group(fullDoc)
            if outputTerminal then
                -- TODO: Add an option to print out flattened
                p.print(flattenPrintOut and flattenedDoc or fullDoc)
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

    --- Asserts that `v` is truthy and if so returns ALL arguments, otherwise assertion error and displays the `message` given.
    --- Also logs fatal if the assertion fails at NoTag
    --- @param v? any -- Why the heck is this optional? I am just following how native assert() works...
    --- @param message? any
    --- @param ...? any
    function this.assert(v, message, ...)
        return this.assertWithTag("", v, message, ...)
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

    --- Some as `Logger.assert` but will run `fn(table.unpack(args))` and `v` is whether it does not errror.
    --- Similarly, instead of returning v it will returns all return values of the function at the front.
    --- @param fn any
    --- @param args any
    --- @param message any
    --- @param ... any
    function this.assertFunctionRuns(fn, args, message, ...)
        return this.assertFunctionRunsWithTag("", fn, args, message, ...)
    end

    function this.assertFunctionRunsWithTag(tag, fn, args, message, ...)
        -- Not actually using assert here for the success case, so if someone was expecting to hook assert then RIP
        local protected = { pcall(fn, table.unpack(args)) }

        if protected[1] then -- Did not error
            table.remove(protected, 1)
            return table.unpack(protected), message, ...
        else
            local pretty_args = {} -- Note: Will end up with a space line in front
            for _, arg in pairs(args) do
                table.insert(pretty_args, p.space_line)
                table.insert(pretty_args, p.pretty(arg))
            end
            local fn_args_msg = p.render(p.concat(p.pretty(fn), p.space, "ran on", table.unpack(pretty_args)))

            return this.assertWithTag(tag, false and fn_args_msg, message .. "\t[ERROR]: " .. protected[2])
        end
    end

    return this
end

return setmetatable(
{
    new = new,
    -- require SHOULD be caching this, so this will only ever be a single instead
    singleton = new().setOutputTerminal(nil).setGlobalLevel(DebugLevel.Verbose).setLogsToKeep(300).setPath("/log/program/" .. (arg and arg[0] .. ".txt" or "unkown_script_name.txt"))
},
{__call = function (_,...)
        new(...)
    end
}
)
