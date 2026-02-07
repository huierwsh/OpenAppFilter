local ds = require "luci.dispatcher"
local nxo = require "nixio"
local nfs = require "nixio.fs"
local ipc = require "luci.ip"
local sys = require "luci.sys"
local utl = require "luci.util"
local dsp = require "luci.dispatcher"
local uci = require "luci.model.uci"
local lng = require "luci.i18n"
local jsc = require "luci.jsonc"

local m, s
arg[1] = arg[1] or ""
m = Map("appfilter", translate(""), translate(""))


local v
v = m:section(SimpleSection)
v.template = "admin_network/app_filter"
return m
-- 编辑文件：package/OpenAppFilter/luci-app-oaf/luasrc/model/cbi/oaf/appfilter.lua
-- 在现有代码末尾（或合适位置）添加以下内容

-- 新增「自定义域名过滤」配置项
local section = m:section(TypedSection, "custom_domain", translate("Custom Domain Filter"))
section.anonymous = true
section.addremove = true  -- 允许添加/删除多条域名规则

-- 域名输入框
local domain = section:option(Value, "domain", translate("Domain Name"))
domain.rmempty = false
domain.description = translate("Input domain to filter, e.g. example.com, *.example.com")

-- 过滤模式（阻止/允许）
local mode = section:option(ListValue, "mode", translate("Filter Mode"))
mode:value("block", translate("Block"))
mode:value("allow", translate("Allow"))
mode.default = "block"

-- 生效时间（可选，复用OAF原有定时逻辑）
local time = section:option(Value, "time_range", translate("Time Range (Optional)"))
time.description = translate("Format: 08:00-22:00, leave empty for always")
