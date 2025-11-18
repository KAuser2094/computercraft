--- TestReporter.lua
local M = {}

-- Escape HTML special characters
local function escape_html(s)
    if s == nil then return "" end
    s = tostring(s)
    s = s:gsub("&", "&amp;")
    s = s:gsub("<", "&lt;")
    s = s:gsub(">", "&gt;")
    s = s:gsub('"', "&quot;")
    s = s:gsub("'", "&#39;")
    return s
end

-- Write a string to file (works in plain Lua and CC:Tweaked with io)
local function write_file(path, contents)
    local f, err = io.open(path, "w")
    if not f then
        return nil, err
    end
    f:write(contents)
    f:close()
    return true
end

--- Generate a standalone HTML report.
--- @param results table The results returned from TestRunner:run()
--- @param path? string Path to write the HTML file (e.g. "/tmp/test_report.html" or "/rom/test_report.html")
--- @return boolean?, string? true on success, or nil + error
function M.generate_html_report(results, path)
    path = path or "test_report.html"
    local html_parts = {}

    table.insert(html_parts, [[
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<title>Test Report</title>
<style>
body { font-family: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial; margin: 18px; background:#f7f8fb; color:#222; }
header { margin-bottom: 18px; }
h1 { margin: 0 0 6px 0; font-size: 20px; }
.summary { margin-bottom: 12px; }
.metrics { display: inline-block; padding: 6px 10px; border-radius: 6px; background: #fff; box-shadow: 0 1px 2px rgba(0,0,0,0.04); margin-right:8px;}
.module { margin-bottom: 14px; background:#fff; border-radius:8px; padding:12px; box-shadow:0 1px 3px rgba(0,0,0,0.04); }
.module h2 { margin:0 0 8px 0; font-size:16px; }
.test { padding:8px; border-radius:6px; margin-bottom:6px; display:flex; align-items:flex-start; justify-content:space-between; }
.test.ok { background: #f0fff4; border: 1px solid #dff2de; }
.test.fail { background: #fff6f6; border: 1px solid #ffd6d6; }
.test .left { flex:1; }
.tname { font-weight:600; }
.tmeta { color:#666; font-size:12px; margin-top:4px; }
.trace { white-space:pre-wrap; font-family: monospace; margin-top:8px; padding:8px; border-radius:6px; background:#111; color:#fff; overflow:auto; max-height:300px; }
.small { font-size:12px; color:#555 }
.details { margin-top:8px; }
.toggle { cursor:pointer; color:#0366d6; text-decoration:underline; font-size:12px; }
.footer { margin-top: 18px; font-size:12px; color:#666; }

/* Ensure details block spans full width under the test row */
.details-wrapper { margin-top:6px; margin-bottom: 6px; padding-left:4px; padding-right:4px; }
.details-wrapper details { background: transparent; border: none; padding: 0; }
.details-wrapper summary { cursor: pointer; color:#0366d6; font-size:13px; margin-bottom:6px; }

/* Content inside details */
.details-content { display:block; margin-top:6px; margin-bottom: 6px; }
.details-content .trace { background:#111; color:#fff; padding:10px; border-radius:6px; }
</style>
</head>
<body>
<header>
<h1>Test Report</h1>
<div class="summary">
]])

    -- Header metrics
    table.insert(html_parts, string.format('<span class="metrics">Total Passed: <strong>%d</strong></span>', results.totalPassed or 0))
    table.insert(html_parts, string.format('<span class="metrics">Total Failed: <strong>%d</strong></span>', results.totalFailed or 0))
    table.insert(html_parts, string.format('<span class="metrics">Modules: <strong>%d</strong></span>', (results.modules and (function() local n=0 for _ in pairs(results.modules) do n=n+1 end return n end)() or 0)))
    table.insert(html_parts, "</div></header>")

    -- Modules
    if results.modules then
        for moduleName, modResult in pairs(results.modules) do
            modResult = modResult or {}
            local passed = modResult.passed or 0
            local failed = modResult.failed or 0
            table.insert(html_parts, string.format('<section class="module"><h2>%s</h2>', escape_html(tostring(moduleName))))
            table.insert(html_parts, string.format('<div class="small">Passed: <strong>%d</strong> — Failed: <strong>%d</strong></div>', passed, failed))

            -- Tests list (iterate deterministically: collect keys then sort)
            local testKeys = {}
            if modResult.tests then
                for k in pairs(modResult.tests) do table.insert(testKeys, k) end
                table.sort(testKeys)
                for _, testName in ipairs(testKeys) do
                    local info = modResult.tests[testName]
                    local ok = info and info.ok
                    local classname = ok and "test ok" or "test fail"

                    -- Render the test row (left: name/meta, right: "show details" summary)
                    table.insert(html_parts, string.format('<div class="%s">', classname))
                    table.insert(html_parts, '<div class="left">')
                    table.insert(html_parts, string.format('<div class="tname">%s</div>', escape_html(tostring(testName))))
                    if ok then
                        table.insert(html_parts, '<div class="tmeta small">Status: <strong>OK</strong></div>')
                    else
                        local err = info.error and tostring(info.error) or "Error"
                        table.insert(html_parts, string.format('<div class="tmeta small">Status: <strong>FAIL</strong> — Error: %s</div>', escape_html(err)))
                    end
                    table.insert(html_parts, '</div>') -- left

                    -- Right column: a simple indicator (kept for layout parity)
                    table.insert(html_parts, '<div style="margin-left:12px; text-align:right;">')
                    table.insert(html_parts, '</div>') -- right
                    table.insert(html_parts, '</div>') -- end .test row

                    -- Now render a details-wrapper AFTER the .test row so it spans full width
                    if not ok then
                        -- Context pretty-printer
                        local ctxText = ""
                        local ok_ctx, json = pcall(function()
                            local function simple_print(v, depth)
                                depth = depth or 0
                                local indent = string.rep("  ", depth)
                                if type(v) == "table" then
                                    local parts = {"{\n"}
                                    local ks = {}
                                    for k in pairs(v) do table.insert(ks, k) end
                                    table.sort(ks, function(a,b) return tostring(a) < tostring(b) end)
                                    for _, k in ipairs(ks) do
                                        table.insert(parts, indent .. "  " .. tostring(k) .. ": " .. simple_print(v[k], depth+1) .. ",\n")
                                    end
                                    table.insert(parts, indent .. "}")
                                    return table.concat(parts)
                                else
                                    return escape_html(tostring(v))
                                end
                            end
                            return simple_print(info and info.ctx or {}, 0)
                        end)
                        ctxText = ok_ctx and json or escape_html(tostring(info and info.ctx))

                        table.insert(html_parts, '<div class="details-wrapper">')
                        table.insert(html_parts, '<details>')
                        table.insert(html_parts, '<summary>Details</summary>')
                        table.insert(html_parts, '<div class="details-content">')

                        table.insert(html_parts, string.format('<div class="small"><strong>Context:</strong><pre class="trace">%s</pre></div>', ctxText))

                        if info and info.traceback then
                            table.insert(html_parts, string.format('<div class="small"><strong>Traceback:</strong><pre class="trace">%s</pre></div>', escape_html(tostring(info.traceback))))
                        end
                        if info and info.error then
                            table.insert(html_parts, string.format('<div class="small"><strong>Error:</strong><div class="trace" style="background:#2b2b2b;">%s</div></div>', escape_html(tostring(info.error))))
                        end

                        table.insert(html_parts, '</div>') -- details-content
                        table.insert(html_parts, '</details>')
                        table.insert(html_parts, '</div>') -- details-wrapper
                    end
                end
            else
                table.insert(html_parts, '<div class="small">No tests found in this module.</div>')
            end

            table.insert(html_parts, '</section>')
        end
    else
        table.insert(html_parts, '<div>No modules found in results.</div>')
    end

    -- Footer
    table.insert(html_parts, string.format('<div class="footer">Generated: %s</div>', escape_html(os.date("%Y-%m-%d %H:%M:%S"))))
    table.insert(html_parts, [[
</body>
</html>
    ]])

    local html = table.concat(html_parts)
    return write_file(path, html)
end

return M
