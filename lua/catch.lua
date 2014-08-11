package.path = inpath .. "/lua/?.lua"
local pppoe_special  = require "pppoe_special"
local lsys = require "lsys"
local lw   = require "lwan"
local resp = {};
local ret;
local updateTitleCmd = "updateconf " .. inpath .. "/conf/load_catch.conf -t Title -v ";
local updateStateCmd = "updateconf " .. inpath .. "/conf/load_catch.conf -t State -v ";
local updateCancelCmd = "updateconf " .. inpath .. "/conf/load_catch.conf -t AtCancelCommand -v ";
local loadCmd = "loadingapp " .. inpath .. "/conf/load_catch.conf 1 &";
os.execute(updateTitleCmd .. " 已迁移0个用户信息...");
os.execute(updateStateCmd .. 0);
os.execute(updateCancelCmd .. inpath .. "/sbin/cancel.sh");
os.execute(loadCmd);
resp.code = -1;
while resp.code ~= 0 and resp.code ~= -2 do
    resp = pppoe_special.get_pppoe_special_info();
    if resp.count == -1 then
        resp.count = 0;
    end
    os.execute(updateTitleCmd .. " 已迁移" .. resp.count .. "个用户信息...");
    os.execute("sleep 2");
end
--print(resp.code);
if resp.code == -2 then
    os.execute(updateStateCmd .. 2);
    ret=1;
    os.exit(ret);
end
os.execute(updateStateCmd .. 2);
ret = 0;
os.exit(ret);
