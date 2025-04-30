return {
    -- cluster config
    conf = {
        main = "127.0.0.1:2528",
        ping = "127.0.0.1:2529",
    },
    -- nodes
    main = {
        id = 1,
        debug_port = 8000
    },
    ping = {
        id = 2,
        debug_port = 8001
    },
}