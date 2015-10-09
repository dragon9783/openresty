local _M = { _VERSION = '0.01' }

local mysql = require('resty.mysql')

local character = 'utf8'
local db_options = {
    host = '172.17.42.1',
    port = 3306,
    user = 'nginx_test',
    password = 'nginx_test',
    database = 'nginx_test'
}



--- 获取连接
--
-- @return resty.mysql MySQL连接
-- @error mysql.socketFailed socket建立失败
-- @error mysql.cantConnect 无法连接数据库
-- @error mysql.queryFailed 数据查询失败
function _M.getClient()
    if ngx.ctx.MySQL then
        return ngx.ctx.MySQL
    end

    local client, errmsg = mysql.new()

    if not client then
        ngx.say("Error")
    end

    client:set_timeout(3000)

    local options = {
        user = db_options.user,
        password = db_options.password,
        database = db_options.database
    }

    if db_options.socket then
        options.path = db_options.socket
    else
        options.host = db_options.host
        options.port = db_options.port
    end

    local ok, errmsg, errno, sqlstate = client:connect(options)

    if not ok then
        ngx.say("failed to connect: ", err, ": ", errno, " ", sqlstate)
        return
    end

    local query = "SET NAMES " .. character
    local result, errmsg, errno, sqlstate = client:query(query)

    if not result then
        ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
        return
    end

    ngx.ctx.MySQL = client

    
    return client
end

--- 关闭连接
function _M.close()
    if ngx.ctx.MySQL then
        ngx.ctx.MySQL:set_keepalive(0, 100)
        ngx.ctx.MySQL = nil
    end
end

--- 执行查询
--
-- 有结果数据集时返回结果数据集
-- 无数据数据集时返回查询影响，如：
-- { insert_id = 0, server_status = 2, warning_count = 1, affected_rows = 32, message = nil}
--
-- @param string query 查询语句
-- @return table 查询结果
-- @error mysql.queryFailed 查询失败
function _M.query(query)

    local result, errmsg, errno, sqlstate = _M.getClient():query(query)

    if not result then
        ngx.say("Error:",errmsg,errno,sqlstate)
    end

    return result
end

return _M