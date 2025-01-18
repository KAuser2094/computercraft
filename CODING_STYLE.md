# Coding Style Guide

This is here because for some reason I keep flip-flop-ing on my coding style, hopefully this will force me to stick to one (-_-). Also is semi-documentation.

( I ended up changing it a bit  still :/ )

## Types

Instructions on using and making types/type-classes (hereby just type) in LuaLS.

### Classes

Look at the `Classes.Types` section,

## Classes

There is a `Class` Module and type that for the most part will be used. However in some cases, like `Logger` closure type classes may be used, in general if the class is self isolated then it is fine to not use the `Class` Module

### Types

Each class will generally end up creating 3/4 types:
- `I<CLASSNAME>Definition` -- This one is optional, ignore if you aren't using it.
- `<CLASSNAME>Definition` (inherits the above if it is being used)
- `I<CLASSNAME>` which holds only the minimum required of an instance (and inherits from `IClass`)
- `<CLASSNAME>` which holds any accessible field of an instance (Also inherits from above if it exists) (and inherits from `Class`)

The `I` definitions are meant for "incomplete" interface-like classes, which require actual implementation by inheriting classes, for the most part this is not used so the `I` definitions are also ignored.

### Class Module

When creating a `Class` you are technically creating a `ClassDefinition` and it is only after the call of "new" that you have a Class. `Class` is a custom extended class implementation that allows for many more features with the aim of extendable functionality. It tries to balance this extensability with ease of implementation and performance (although it is lua and performance isn't the top priority)

#### self vs this

(The reason why I even made this dumb file)

- If function is to be called by the definition itself, use `:` notation and `self` (which will automatically have the correct type)
- If function is to be called the the instance, use `.` notation and `this` (and type `this` to be that class' type)
- If function could be both, use `:` notation, the actually instance's type is a manually defined and you should change the `self` of the function to include the instance there.

Of course, if you are defining the functions elsewhere and simply assigning them into the class then you will HAVE to use `.` notation, where you would use `:` notation just manually put the `self` in.

Also if the function is taking in an instance then you should likely be calling it `this`, `inst` or `instance` can also work but `this` is arguably more consistent.

```
...
    Class.z = 5 -- Class/"static" (I believe this is what C# would call these) variable

    function Class:init(this, x, y) -- init is called by definition and taking in an instance, so `:` and `this` both
        -- Instance variables
        this.x = x
        this.y = y
    end

    --- ...comments go here...
    function Class:getZ() -- Uses static variables so we use ":"
        return self.z
    end

    --- ...comments go here...
    function Class.x(this) -- Uses an instance variable (so expects an instance) so we use "." and this 
        return this.x
    end
...
```

#### new

The new method should always be a call and return of `:rawnew(...)`, it is just here to cast the type to the actual Class instead of `Class`.

#### init

If inheriting something with an `init` you MUST include your own `init` that calls that base classes' `init` amd passes in the args. I believe it could technically still work, however the inheritance will not be consistent with multiple bases,

## Logger

Logger is/can be used not just as a debugging tool but to easily print out information to the user.

### As a debugging tool

If the logger is simply being used as a debugging tool then you should be using the singleton logger. (This is created whenever the file is first `require`-d and uses the fact `require` will cache it for that program). Instead of `.new` call `.singleton` and set the level of the tag to log at (If not debugging then usually `Error` or `Warning`)

### Other

In other cases you generally want each class to define their own logger. (Or have it be passed in as an argument, so connected systems can share the same logger). Ideally changing the log location to `log/<appropriate name>`