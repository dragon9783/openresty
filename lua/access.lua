
ngx.var.limit_rate = "100K"

local tokentool = require "comm.tokentool"
local args = ngx.req.get_uri_args()
-- ngx.say(args.token)
if args.token == nil then
        ngx.exit(ngx.HTTP_FORBIDDEN)
end
local ret = tokentool.has_token(args.token)
if ret == ngx.null then
        ngx.exit(ngx.HTTP_FORBIDDEN)
elseif ret == false then
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end
ngx.req.set_uri_args({token=ret})