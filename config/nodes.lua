return {
    -- cluster config
    conf = {
        main = "127.0.0.1:2528",
        ping = "127.0.0.1:2529",
    },
    -- nodes
    main = {
        debug_port = 8000
    },
    ping = {
        debug_port = 8001
    },
}