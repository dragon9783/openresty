-- package.path = package.path .. ";/labrory/openresty/lua/?.lua"

local mysql = require("comm.mysql")
local json = require('cjson')

local query = "select * from cats;"
ngx.say(json.encode(mysql.query(query)))

-- ngx.say(ngx.ctx[MySQL])

-- ngx.say(package.path)