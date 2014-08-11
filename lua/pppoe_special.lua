-- for pppoe-server catch
package.path = '/system/share/lua/5.1/?.lua'
local wan_api = require "wan_api"
local string  = require "string";
local cwan    = require "cwan";
local lsys    = require "lsys";
local csys    = require "csys";
local util    = require "lutil"
require "lwan";
module("pppoe_special", package.seeall)

function get_pppoe_special_info()
    local respmsg = {};
    local lockFile = "getSpecialInfo.lock"
    local cmd = inpath .. "/sbin/pppoe-catch.sh &"
    local ret, time = lutil.checkLock(lockFile);
    if ret then
        if time > 100 then
            respmsg.code = -2;
            respmsg.count = 0;
            respmsg.msg  = "get special info timeout";
            lutil.delLock(lockFile);
            local clearCmd = inpath .. "/sbin/pppoe-catch-clear.sh &"
            os.execute(clearCmd);
            return respmsg;
        else
            local status = get_pppoe_special_info_status();
            if status == -1 then
                respmsg.code = -1;
                respmsg.count = get_pppoe_special_info_code();
                respmsg.msg = "have get " .. respmsg.count .. " special info"
                if respmsg.count == 10 then
                    respmsg.code = 0;
                    respmsg.count = 10;
                    respmsg.msg = "get special info done";
                    lutil.delLock(lockFile);
                    local clearCmd = inpath .. "/sbin/pppoe-catch-clear.sh &"
                    os.execute(clearCmd);
                end
                return respmsg;
            else
                respmsg.code = 0;
                respmsg.count = get_pppoe_special_info_code();
                respmsg.msg = "get special info done";
                lutil.delLock(lockFile);
                local clearCmd = inpath .. "/sbin/pppoe-catch-clear.sh &"
                os.execute(clearCmd);
                return respmsg;
            end
        end
    else
        lutil.addLock(lockFile);
        os.execute(cmd);
        respmsg.code = -1;
        respmsg.count = 0;
        respmsg.msg = "get special info..."
        return respmsg;
    end
end

function get_pppoe_special_info_code()
    local resp;
    local codeFile="/var/run/catch.code";
    local handle = io.open(codeFile, 'r');
    if handle then
        local ret = handle:read("*a");
        handle:close();
        resp = tonumber(ret);
        return resp;
    end
    resp = 0;
    return resp;
end


function get_pppoe_special_info_status()
    local resp;
    local statusFile="/var/run/catch.status";
    local handle = io.open(statusFile, 'r');
    if handle then
        local ret = handle:read("*a");
        handle:close();
        resp = tonumber(ret);
        return resp;
    end
    resp = -1;
    return resp;
end

function set_pppoe_special_dial(countindex)
    local respmsg = {};
    local lockFile = "setSpecialDial.lock";
    local specialFile = "/tmp/catch"; 
    local index = tonumber(countindex);
    local handle = io.open(specialFile);
    local i;
    local userName;
    local passWord;
    local rmCmd;

    if handle then 
        for i = 1, index, 1 do
            handle:read("*line");
            handle:read("*line");
        end
        local userName_tmp = handle:read("*line");
        if userName_tmp == nil then
            respmsg.code = -2;
            respmsg.msg  = "special dial null";
            lutil.delLock(lockFile);
            return respmsg;
        end
        userName = string.sub(userName_tmp, 2, string.len(userName_tmp)-1);
        local passWord_tmp = handle:read("*line");
        if passWord_tmp == nil then
            respmsg.code = -2;
            respmsg.msg  = "special dial null";
            lutil.delLock(lockFile);
            return respmsg;
        end
        passWord = string.sub(passWord_tmp, 2, string.len(passWord_tmp)-1);
        local testCmd = "echo " .. passWord .. " " .. ">" .. "/var/run/tmp"
        os.execute(testCmd);
    end
    local ret, time = lutil.checkLock(lockFile);
    if ret then
        if time > 100 then
            respmsg.code = -2;
            respmsg.msg  = "special dial timeout";
            lutil.delLock(lockFile);
            return respmsg;
        else
        rmCmd = "rm /var/run/pppcode";
        os.execute(rmCmd);
            local pppoeRet = wan_api.get_status_pppoe();
            if pppoeRet.code ~= -1 then
                lutil.delLock(lockFile);
            end
            pppoeRet.username = userName;
            pppoeRet.password = passWord;
            return pppoeRet; 
        end
    else
        lutil.addLock(lockFile);
        -- if first time to dial, may take a log time
        rmCmd = "rm /var/run/pppcode";
        os.execute(rmCmd);
        if index == 0 then
            local wan_config = {};
            wan_config.type = "PPPOE";
            wan_config.account = userName;
            wan_config.password = passWord;
            wan_config.pppoe_method = "KeepAlive"; 
            wan_config.pedial_period = 30; 
            wan_config.idle_time = 300; 
            wan_config.mtu = 1492;
            wan_api.set_config(wan_config);
            respmsg.code = -1;
            respmsg.msg  = "special dial ...";
            respmsg.username = userName;
            respmsg.password = passWord;
        else
            local pppoeChangeCmd = inpath .. "/sbin/pppoe-change.sh " .. userName .. " " .. passWord
            os.execute(pppoeChangeCmd);
            local pppoeEasyCmd = inpath .. "/sbin/pppoe-easy.sh";
            os.execute(pppoeEasyCmd);
            respmsg.code = -1;
            respmsg.msg  = "special dial ...";
            respmsg.username = userName;
            respmsg.password = passWord;
        end
        wan_api.get_status_pppoe();
        return respmsg;
    end
end
