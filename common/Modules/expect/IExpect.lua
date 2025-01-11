--- @meta
--- Interface to implement "__expect: fun(type: any): boolean" for "expect" module to use

--- @class common.Modules.expect.IExpect
--- @field __expect fun(self, type: any):boolean
--- @field __expectGetTypes fun(self):any[]
local IExpect = {}
