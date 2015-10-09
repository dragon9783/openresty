local json = require('cjson')
ngx.say('hello openresty!!!')
function short(url)
    local shortUrl = ngx.md5(url):sub(1, length)
    return shortUrl
end
local args = ngx.req.get_uri_args()
local url = args["url"]
local shortUrl = short(url)

ngx.say(json.encode(args))
ngx.say(url)
ngx.say(shortUrl)