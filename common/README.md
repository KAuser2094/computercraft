# Common

Shared `common` files between apps/programs.

## Modules

### Logger.lua

Based off: https://gitlab.com/ralphgod3/cctutorials/-/blob/master/Modules/Logger.lua?ref_type=heads.

Always the user to log at different severities and with different tags.

There is a global level of severity (default: `Verbose`) and you can tag a message to log on the verbosity of the tag, if it has not been set then it will default set that tag to the global level.

Levels (in order) are:
- None
- Temporary (This is what `NoTag` or `tag=""` is set to)
- Fatal
- Error
- Warning
- Info
- Debug
- Verbose

So, `None` < `Temporary` < `Fatal` < `Error` < `Warning` < `Info` < `Debug` < `Verbose`. And you will only log if the level you are logging at is below the level of the tag you are working in.