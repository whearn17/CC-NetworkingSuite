function send(id, message)
    return rednet.send(id, message)
end

function recv()
    return rednet.receive()
end
