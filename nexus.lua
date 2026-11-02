--[[\
	Protected by NEXUS Security Systems
--]]
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i - f%2^(i-1) > 0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d%d%d%d%d%d', function(x)
        return string.char(tonumber(x, 2))
    end))
end

local encoded_script = "TG9jYWwgUGxheWVycyA9IGdhbWU6R2V0U2VydmljZSgiUGxheWVycyIpCmxvY2FsIFJ1blNlcnZpY2UgPSBnYW1lOkdldFNlcnZpY2UoIlJ1blNlcnZpY2UiKQpsb2NhbCBVc2VySW5wdXRTZXJ2aWNlID0gZ2FtZTpHZXRTZXJ2aWNlKCJVc2VySW5wdXRTZXJ2aWNlIikKbG9jYWwgVmlydHVhbFVzZXIgPSBnYW1lOkdldFNlcnZpY2UoIlZpcnR1YWxVc2VyIikKbG9jYWwgVGV4dENoYXRTZXJ2aWNlID0gZ2FtZTpHZXRTZXJ2aWNlKCJUZXh0Q2hhdFNlcnZpY2UiKQpsb2NhbCBUd2VlblNlcnZpY2UgPSBnYW1lOkdldFNlcnZpY2UoIlR3ZWVuU2VydmljZSIpCmxvY2FsIFN0YXRzID0gZ2FtZTpHZXRTZXJ2aWNlKCJTdGF0cyIpCmxvY2FsIExpZ2h0aW5nID0gZ2FtZTpHZXRTZXJ2aWNlKCJMaWdodGluZyIpCmxvY2FsIENhbWVyYSA9IHdvcmtzcGFjZS5DdXJyZW50Q2FtZXJhCmxvY2FsIExvY2FsUGxheWVyID0gUGxheWVycy5Mb2NhbFBsYXllcgoKbG9jYWwgS2V5UmF3VVJMID0gImh0dHBzOi8vcmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbS9ueXdlcnR5eS1kZXYvbmV4dXMtc2NyaXB0L21haW4va2V5LnR4dCIKbG9jYWwgVGVsZWdyYW1MaW5rID0gImh0dHBzOi8vdC5tZS8rSjQ1aDVFRzJtSll4WkRneSIK"

-- Запуск расшифрованного кода в памяти
local func, err = loadstring(dec(encoded_script))
if func then
    func()
else
    warn("Error loading NEXUS:", err)
end
