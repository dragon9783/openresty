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
ngx.say(ngx.req.get_headers()["Authorization"])
ngx.say(ngx.req.get_headers()["Accept"])
local auth = ngx.req.get_headers()["Authorization"]
t = {}
     s = "Basic YWRtaW46cGFzc3dvcmQ="
     for k, v in string.gmatch(s, "(%w+)%s(%w+)") do
       t[k] = v
     end
     ngx.say(json.encode(t))

     ngx.status = 404 
	ngx.say("hello") 
ngx.say(os.getenv("PATH"))
ngx.say(os.getenv("MYSQL_SERVICE_NAME"))
ngx.say(os.getenv("MYSQL_USER_NAME"))
