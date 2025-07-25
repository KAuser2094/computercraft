--- @meta _

--- @alias common.Modules.Tabula.Relation.Source any
--- @alias common.Modules.Tabula.Relation.Target any

--- @alias common.Modules.Tabula.Relation.SourceToTarget { [common.Modules.Tabula.Relation.Source] : Set<common.Modules.Tabula.Relation.Target> }
--- @alias common.Modules.Tabula.Relation.TargetToSource { [common.Modules.Tabula.Relation.Target] : Set<common.Modules.Tabula.Relation.Source> }


--- @class common.Modules.Tabula.Relation : common.Modules.Class.Class
--- @field sourceLinks common.Modules.Tabula.Relation.SourceToTarget
--- @field targetLinks common.Modules.Tabula.Relation.TargetToSource
local Relation = {}

--- @param this common.Modules.Tabula.Relation
--- @param source any
--- @param target any
function Relation.link(this, source, target) end

--- @param this common.Modules.Tabula.Relation
--- @param source any
--- @param target any
function Relation.unlink(this, source, target) end
