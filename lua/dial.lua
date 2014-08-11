package.path = inpath .. "/lua/?.lua"
local pppoe_special = require "pppoe_special"
local lsys = require "lsys"
local resp = {};
local ret;
local updateTitleCmd = "updateconf " .. inpath .. "/conf/load_dial.conf -t Title -v ";
local updateStateCmd = "updateconf " .. inpath .. "/conf/load_dial.conf -t State -v ";
local updateCancelCmd = "updateconf " .. inpath .. "/conf/load_catch.conf -t AtCancelCommand -v ";
local loadCmd = "loadingapp " .. inpath .. "/conf/load_dial.conf 1 &";
os.execute(updateTitleCmd .. " 使用第0个信息拨号中...");
os.execute(updateStateCmd .. 0);
os.execute(updateCancelCmd .. inpath .."/sbin/cancel.sh");
os.execute(loadCmd);
local countCmd = "cat /tmp/catch | wc -l";
count_tmp = lsys.shellpexec(countCmd);
local count = tonumber(count_tmp)/2;
local i;

for i=0, count, 1 do
    os.execute(updateTitleCmd .. " 使用第" .. i+1 .. "个信息拨号中...");
    resp = pppoe_special.set_pppoe_special_dial(i);
    while resp.code == -1 do
        resp = pppoe_special.set_pppoe_special_dial(i);
        os.execute("sleep 1");
    end
    if resp.code == 0 then
        os.execute(updateStateCmd .. 2);
        ret = 0;
        os.exit(ret);
    end
end
local pppdCmd = "killall pppd";
--print(resp.code);
os.execute(pppdCmd);
os.execute(updateStateCmd .. 2);
ret=1;
os.exit(ret);
