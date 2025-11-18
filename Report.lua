TestReporter = require "common.Modules.Test.TestReporter"
TestRunner = require "common.Modules.Test.TestRunner"
ClassTest = require "test.Class"
ExpectTest = require "test.Expect"

local tr = TestRunner:new()

tr:addModule(ClassTest)
tr:addModule(ExpectTest)

local results = tr:run()

local success = TestReporter.generate_html_report(results)

if success then
    print("HTML Test Report Created")
else
    print("HTML Test Report Failed To Be Created")
end
