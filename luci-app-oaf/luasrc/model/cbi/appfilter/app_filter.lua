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
m = Map("appfilter", translate("App Filter"), translate("App Filter Configuration"))

-- 原有模板渲染（保留不动）
local v
v = m:section(SimpleSection)
v.template = "admin_network/app_filter"

-- ========== 新增「自定义域名过滤」配置项（放在原有代码后） ==========
local section = m:section(TypedSection, "custom_domain", translate("Custom Domain Filter"))
section.anonymous = true  -- 匿名节，不显示节名称
section.addremove = true  -- 允许添加/删除多条域名规则
section.sortable = true   -- 允许排序（可选，提升体验）
section.template = "cbi/tblsection"  -- 表格样式显示，更美观

-- 1. 域名输入框
local domain = section:option(Value, "domain", translate("Domain Name"))
domain.rmempty = false  -- 不能为空
domain.description = translate("Input domain to filter, e.g. example.com, *.example.com")
domain.size = 30  -- 输入框宽度，提升体验

-- 2. 过滤模式（阻止/允许）
local mode = section:option(ListValue, "mode", translate("Filter Mode"))
mode:value("block", translate("Block"))
mode:value("allow", translate("Allow"))
mode.default = "block"
mode.rmempty = false

-- 3. 生效时间（可选）
local time_range = section:option(Value, "time_range", translate("Time Range (Optional)"))
time_range.description = translate("Format: 08:00-22:00, leave empty for always")
time_range.size = 15

-- ========== 保存逻辑（仅优化1行：移除重定向，避免路径问题） ==========
m.submit = translate("Save All Config")
m.on_after_commit = function(self)
    -- 保存后重启appfilter服务，确保规则生效
    luci.sys.call("/etc/init.d/appfilter restart >/dev/null 2>&1")
    -- 注释/删除这行重定向，避免路径不匹配导致的404（Map会自动留在当前页面）
    -- luci.http.redirect(luci.dispatcher.build_url("admin/services/appfilter"))
end

return m
