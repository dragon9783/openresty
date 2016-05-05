local mysql = require "resty.mysql"
local tokentool = require "comm.tokentool"

local json = require('cjson')

-- post only
local method = ngx.req.get_method()
if method ~= "POST" then
    ngx.exit(ngx.HTTP_FORBIDDEN)
    return
end

-- get args
local args = ngx.req.get_uri_args(10)
if args.act ~= "register" and args.act ~= "login" and args.act ~= "logout" and args.act ~= "updatepwd" then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
    return
end

ngx.req.read_body()
local postargs = ngx.req.get_post_args(10)
-- local postargs = ngx.req.get_post_args(10)

-- connect to mysql;
local function connect()
    local db, err = mysql:new()
    if not db then
        return false
    end
    db:set_timeout(1000)
    
    local ok, err, errno, sqlstate = db:connect{
        host = "172.17.42.1",
        port = 3306,
        database = "nginx_test",
        user = "root",
        password = "password",
        max_packet_size = 1024 * 1024 }
    
    if not ok then
        return false
    end
    return db
end


function register(pargs)
    if pargs.username == nil then
        pargs.username = ""
    end
    if pargs.email == nil or pargs.password == nil then
        ngx.exit(ngx.HTTP_BAD_REQUEST)
        return
    end
    
    local db = connect()
    if db == false then
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
        return
    end
    
    local res, err, errno, sqlstate = db:query("insert into account(username, password, email) "
                             .. "values (\'".. pargs.username .."\',\'".. pargs.password .."\',\'".. pargs.email .."\')")
    if not res then
        ngx.exit(ngx.HTTP_NOT_ALLOWED)
        return
    end

    local uid = res.insert_id
    local token, rawtoken = tokentool.gen_token(uid)

    local ret = tokentool.add_token(token, rawtoken)
    if ret == true then
        ngx.say(token)
    else
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
end

function login(pargs)
    if pargs.email == nil or pargs.password == nil then
        ngx.exit(ngx.HTTP_BAD_REQUEST)
        return
    end
    
    local db = connect()
    if db == false then
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
        return
    end
    
    local res, err, errno, sqlstate = db:query("select uid from account where email=\'".. pargs.email .."\' and password=\'".. pargs.password .."\' limit 1", 1)
    if not res then
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
        return
    end
    --local cjson = require "cjson"
    --ngx.say(cjson.encode(res))
    if res[1] == nil then
        ngx.exit(ngx.HTTP_FORBIDDEN)
    end
    local uid = res[1].uid
    local token, rawtoken = tokentool.gen_token(uid)

    local ret = tokentool.add_token(token, rawtoken)
    if ret == true then
        ngx.say(token)
    else
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
end

function logout(pargs)
    if pargs.token == nil then
        ngx.exit(ngx.HTTP_BAD_REQUEST)
        return
    end

    tokentool.del_token(pargs.token)
    ngx.say("ok")
end

-- to be done
function updatepwd(pargs)
    local db = connect()
    if db == false then
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
        return
    end
    ngx.say(pargs.username .. pargs.newpassword)
end

if args.act == "register" then
    register(postargs)
elseif args.act == "login" then
    -- ngx.say("post login")
    login(postargs)
elseif args.act == "updatepwd" then
    updatepwd(postargs)
elseif args.act == "logout" then
    logout(postargs)
end