local jwt = require "resty.jwt"

local token = nil
-- first try to find JWT token in Authorization header Bearer string
local auth_header = ngx.var.http_Authorization
if auth_header then
    _, _, token = string.find(auth_header, "Bearer%s+(.+)")
end

-- next try to find JWT token as url parameter e.g. ?token=BLAH
if token == nil then
    token = ngx.var.arg_token
end

-- finally, if still no JWT token, kick out an error and exit
if token == nil then
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.say("{\"message\":\"Token is invalid\",\"status_code\":401}")
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

-- validate any specific claims you need here
-- https://github.com/SkyLothar/lua-resty-jwt#jwt-validators
local validators = require "resty.jwt-validators"
local claim_spec = {
    validators.set_system_leeway(5), -- time in seconds
    exp = validators.is_not_expired(),
    -- iat = validators.is_not_before(),
    -- iss = validators.opt_matches("^http[s]?://yourdomain.auth0.com/$"),
    -- sub = validators.matches("^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$"),
    -- name = validators.equals_any_of({ "John Doe", "Mallory", "Alice", "Bob" }),
}

-- make sure to set and put "env JWT_SECRET;" in nginx.conf
local jwt_obj = jwt:verify(os.getenv("JWT_SECRET"), token, claim_spec)
if not jwt_obj["verified"] then
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.log(ngx.WARN, jwt_obj.reason)
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.say("{\"message\":\"" .. jwt_obj.reason .. "\",\"status_code\":401}")
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

-- headers exported by lua don't appear in limit_req_zone
-- so ngx_http_limit_req_module doesn't work
local limit_req = require "resty.limit.req"
-- limit the requests under 1 req/sec with a burst of 2 req/sec
local lim, err = limit_req.new("userid_limit_req_store", 1, 2)
if not lim then
    ngx.log(ngx.ERR,
            "failed to instantiate a resty.limit.req object: ", err)
    return ngx.exit(500)
end

-- per user id
local delay, err = lim:incoming(jwt_obj.payload.sub, true)
if not delay then
    if err == "rejected" then
        return ngx.exit(503)
    end
    ngx.log(ngx.ERR, "failed to limit req: ", err)
    return ngx.exit(500)
end

if delay >= 0.001 then
    -- the 2nd return value holds the number of excess requests
    -- per second for the specified key. for example, number 31
    -- means the current request rate is at 231 req/sec for the
    -- specified key.
    local excess = err

    -- the request exceeding the 200 req/sec but below 300 req/sec,
    -- so we intentionally delay it here a bit to conform to the
    -- 200 req/sec rate.
    ngx.sleep(delay)
end
