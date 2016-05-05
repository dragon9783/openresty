local _M = { _VERSION = '0.01' }


local redis = require "resty.redis"

local aes = require "resty.aes"
local str = require "resty.string"

local alive_time = 3600 * 24 
local redis_host = "172.17.42.1"
local redis_port = 6379

function connect()
    local red = redis:new()
    red:set_timeout(1000)
    local ok, err = red:connect(redis_host, redis_port)
    if not ok then
        return false
    end
    ok, err = red:select(1)
    if not ok then
        return false
    end
    return red
end

function _M.add_token(token, raw_token, username)
    local red = connect()
    if red == false then
        return false
    end

    local ok, err = red:setex(token, alive_time, raw_token, username)
    if not ok then
        return false
    end
    return true
end

function _M.del_token(token)
    local red = connect()
    if red == false then
        return
    end
    red:del(token)
end

function _M.has_token(token)
    local red = connect()
    if red == false then
        return false
    end

    local res, err = red:get(token)
    if not res then
        return false
    end
    return res
end

-- generate token
function _M.gen_token(username)
    local rawtoken = username .. " " .. ngx.now()

    -- local aes_128_cbc_md5 = aes:new("secret_key")
    -- local encrypted = aes_128_cbc_md5:encrypt(rawtoken)
    local token = ngx.md5(rawtoken)
    return token, rawtoken
end

return _M