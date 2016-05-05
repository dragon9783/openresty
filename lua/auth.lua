-- local mysql = require "resty.mysql"
-- local tokentool = require "comm.tokentool"

-- local json = require('cjson')

-- -- get only
-- local method = ngx.req.get_method()
-- if method ~= "GET" then
--     ngx.exit(ngx.HTTP_FORBIDDEN)
--     return
-- end

-- -- connect to mysql;
-- local function connect()
--     local db, err = mysql:new()
--     if not db then
--         return false
--     end
--     db:set_timeout(1000)
    
--     local ok, err, errno, sqlstate = db:connect{
--         host = "172.17.42.1",
--         port = 3306,
--         database = "nginx_test",
--         user = "root",
--         password = "password",
--         max_packet_size = 1024 * 1024 }
    
--     if not ok then
--         return false
--     end
--     return db
-- end

-- function auth_by_basic(user_info)

-- 	local userinfo = {}
-- 	for username, password in string.gmatch(ngx.decode_base64(user_info), "(%w+@%w+.%w+):(.*)") do
-- 		userinfo["username"] = username
-- 		userinfo["password"] = password
-- 	end

-- 	-- ngx.header.content_type = 'application/json';

-- 	-- ngx.say(userinfo['username'])
-- 	-- ngx.say(userinfo['password'])

-- 	local db = connect()
--     if db == false then
--         ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
--         return
--     end
    
--     local res, err, errno, sqlstate = db:query("select uid from account where email=\'".. userinfo["username"] .."\' and password=\'".. userinfo["password"] .."\' limit 1", 1)
--     if not res then
--         ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
--         return
--     end
--     -- ngx.say(cjson.encode(res))
--     if res[1] == nil then
--         ngx.exit(ngx.HTTP_FORBIDDEN)
--     end
--     local uid = res[1].uid

--     local token, rawtoken = tokentool.gen_token(userinfo["username"])
--     local ret = tokentool.add_token(token, userinfo["username"])
--     if ret == true then
--     	ngx.header.content_type = 'application/json';
--         ngx.say("{'token': '"..token.."'}")
--     else
--         ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
--     end
-- end

-- function auth_by_token(token, url)
-- 	local res = tokentool.has_token(token)
-- 	if res == ngx.null then
-- 		ngx.status = 401 
-- 		return ngx.exit(401)
-- 	end

	
-- 	-- ngx.say(res)
-- 	response = ngx.location.capture(url,
--          { method = ngx.HTTP_GET, header = "User:" .. res});

--      ngx.print(response.body)
-- end

-- local request_uri = ngx.var.request_uri
-- -- ngx.say(request_uri)

local auth_req = ngx.req.get_headers()["Authorization"]
local auth = {}
for type, info in string.gmatch(auth_req, "(%w+)%s(%w+)") do
	auth["type"] = type
	auth["info"] = info
end

if auth['type'] == "Basic" then
	ngx.say('Basic function')
	-- auth_by_basic(auth['info'])
elseif auth['type'] == "Token" then
	ngx.say('Token function')
	-- auth_by_token(auth['info'],request_uri)
else
end
