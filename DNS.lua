os.loadAPI("/CC-Tools/extrastring.lua")
os.loadAPI("/CC-Tools/easyfile.lua")
local protocol = "nl"
local name = os.getComputerLabel()
local hosts = "/logs/hosts.log"
local logpath = "/logs/dns.log"

function host() --Binds the protocol and username for other PC's to look up
    rednet.host(protocol, name)
end

function unhost() --Unbinds protocol and username
    rednet.unhost(protocol, name)
end

function lookup(dnsID, hostname) --Looks up a hostname using specified DNS server
    rednet.send(dnsID, "lookup: "..hostname, "nl")
    local id, message = rednet.receive("nl")
    return message
end

function listen() --Waits for a lookup from a user
    local id, hostname = rednet.receive("nl")
    print(hostname)
    easyfile.log(logpath, hostname:sub(0, 7).." "..id.." ->"..hostname:sub(8))
    findHost(id, hostname:sub(9))
end

function findHost(id, hostname) --Checks to see if a host exists
	local addr = easyfile.search(hosts, hostname)
    if addr then
		addr = addr:sub(0, extrastring.find(addr, ":"))     
	end
	reply(id, addr)   
end

function reply(id, addr) --Reply to request
    if addr then
        print("lookup reply: "..id.." success")
        easyfile.log(logpath, "lookup reply: success -> "..id)
        rednet.send(id, addr, "nl")
    else
        print("lookup reply: "..id.." fail")
        easyfile.log(logpath, "lookup reply: fail -> "..id)
        rednet.send(id, nil, "nl")
    end
end
