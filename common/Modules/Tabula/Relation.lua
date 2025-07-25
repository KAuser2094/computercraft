local Class = require "common.Modules.Class"

local pc = require "common.Modules.expect"
local TAG = "RELATION"
pc.enableTag(TAG)

--- @class common.Modules.Tabula.RelationDefinition : common.Modules.Class.ClassDefinition
local Relation = Class(TAG)

--- Ceaates a new relation
--- @param sourceLinks? table
--- @param targetLinks? table
--- @return common.Modules.Tabula.Relation
function Relation:new(sourceLinks, targetLinks)
    --- @type common.Modules.Tabula.Relation
    return Relation:rawnew(sourceLinks, targetLinks)
end

--- @param this common.Modules.Tabula.Relation
--- @param sourceLinks? common.Modules.Tabula.Relation.SourceToTarget
--- @param targetLinks? common.Modules.Tabula.Relation.TargetToSource
function Relation:init(this, sourceLinks, targetLinks)
    if sourceLinks and targetLinks then
        this.sourceLinks = sourceLinks
        this.targetLinks = targetLinks
    elseif sourceLinks then
        this.sourceLinks = sourceLinks
        this.targetLinks = {}
        for source, targets in pairs(sourceLinks) do
            for target, _ in pairs(targets) do
                if not this.targetLinks[target] then
                    this.targetLinks[target] = {}
                end
                this.targetLinks[target][source] = true
            end
        end
    elseif targetLinks then
        this.targetLinks = targetLinks
        this.sourceLinks = {}
        for target, sources in pairs(targetLinks) do
            for source, _ in pairs(sources) do
                if not this.sourceLinks[source] then
                    this.sourceLinks[source] = {}
                end
                this.sourceLinks[source][target] = true
            end
        end
    else
        error("Tabula.Relation.init: Needs at least a source or target links")
    end
end

--- @param this common.Modules.Tabula.Relation
--- @param source any
--- @param target any
function Relation.link(this, source, target)
    this.sourceLinks[source] = this.sourceLinks[source] or {}
    this.targetLinks[target] = this.targetLinks[target] or {}

    this.sourceLinks[source][target] = true
    this.targetLinks[target][source] = true
end

--- @param this common.Modules.Tabula.Relation
--- @param source any
--- @param target any
function Relation.unlink(this, source, target)
    -- We presume links were properly madde
    if this.sourceLinks[source][target] then
        this.sourceLinks[source][target] = nil
        this.targetLinks[target][source] = nil
        -- Remove empty tables
        if not next(this.sourceLinks[source]) then
           this.sourceLinks[source] = nil
        end
        if not next(this.targetLinks[target]) then
           this.targetLinks[target] = nil
        end
    end
end


return Relation
