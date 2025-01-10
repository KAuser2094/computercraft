# Coding Style Guide

This is here because for some reason I keep flip-flop-ing on my coding style, hopefully this will force me to stick to one (-_-). Also is semi-documentation.

## Classes

There is a `Class` Module and type that for the most part will be used. However in some cases, like `Logger` closure type classes may be used, in general if the class is self isolated then it is fine to not use the `Class` Module

### Class Module

When creating a `Class` you are technically creating a `ClassDefinition` and it is only after the call of "new" that you have a Class. `Class.Simple` is closer to conventional metatable-based classes for lua, while following the `IClass` type and including inheritance. `Class` is a custom extended class implementation that allows for many more features with the aim of extendable functionality. Always use `Class.Simple` where possible.

#### self vs this

(The reason why I even made this dumb file)

If the function is to be used EXCLUSIVELY on the INSTANCE, define the function with the dot notation with `this` as the first argument. And obviously, vice versa, if the function can be ran on either the `ClassDefinition` or `Class` OR exculsively the `ClassDefinition` then define the functon using the colon notation (which will automatically set `self` as the first argument)

Notably, `new` does not follow this but that is simply because I found `<ClassDef>:new()` to look weird and not for any other logical reason. (Which I am pretty sure some languages actually have that as a format).

Although as each class usually redefines `new` to cast the return type and change the function hint you could easily just make it `:new` and it work work just fine. (As the automatic `self` would just be left unused and the remaining args would be passed into `_new`)

```
...
    Class.z = 5 -- Class/"static" (I believe this is what C# would call these) variable

    function Class.init(this, x, y) -- init is taking in an instance, hence "." and "this"
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

The new method should always be a call and return of `._new`, it is just here to cast the type to the actual Class instead of `IClass`.

#### init

If inheriting something with an `init` you MUST include your own `init` that calls that base classes' `init` amd passes in the args. Otherwise, the default `init` simply does nothing.

## Logger

Logger is/can be used not just as a debugging tool but to easily print out information to the user.

### As a debugging tool

If the logger is simply being used as a debugging tool then you should be using the singleton logger. (This is created whenever the file is first `require`-d and uses the fact `require` will cache it for that program). Instead of `.new` call `.singleton` and set the level of the tag to log at (If not debugging the usually `Error`)

### Other

In other cases you generall want each class to define their own logger. (Or have it be passed in as an argument, so connected systems can share the same logger). Ideally changing the log location to `log/<appropriate name>`