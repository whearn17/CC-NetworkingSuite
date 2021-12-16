os.loadAPI("/CC-Tools/easyfile.lua")
local protocol = "dhcp"
local logpath = "/logs/dhcp.log"
local hosts = "/logs/hosts.log"
local hostinfo = "/hostinfo/hostinfo.log"
local name = os.getComputerLabel()
local uid = os.getComputerID()


function host() --Binds the protocol and username for other PC's to look up
    rednet.host(protocol, name)
end

function unhost() --Unbinds protocol and username
    rednet.unhost(protocol, name)
end

function check(id, hostname) --Checks if host exists
	local err = nil
    if fs.exists(hosts) then
        if easyfile.search(hosts, id..": ") then
            err = "id"
        elseif easyfile.search(hosts, ": "..hostname) then
			err = "hostname"
        end
    end
	reply(id, hostname, err)
end

function listen() --Waits for a request from client
    local id, message = rednet.receive("dhcp")
    print(message:sub(0, 9)..id.." -> "..message:sub(10))
    easyfile.log(logpath, message:sub(0, 9)..id.." -> "..message:sub(10))
    check(id, message:sub(10))
end

function request(server) --Requests a name binding from server
    rednet.send(server, "request: "..os.getComputerLabel(), "dhcp")
    local id, message = rednet.receive("dhcp")
    if message:find("denied") then
        print(message)
    else
        easyfile.write(hostinfo, "Hostname: "..os.getComputerLabel().."\nID: "..uid)
        print("request accepted")
    end    
end

function reply(id, hostname, err) --Replies to client request
    if err then
        print("reply: "..id.." -> "..hostname.." fail")
        easyfile.log(logpath, "reply: "..id.." -> "..hostname.." fail")
        rednet.send(id, "denied:"..err, "dhcp")
    else
        print("reply: "..id.." -> "..hostname.." success")
        easyfile.log(logpath, "reply: "..id.." -> "..hostname.." success")
        easyfile.append(hosts, id..": "..hostname)
        rednet.send(id, "registered", "dhcp")
    end
end
