local indexes = {
    users = {
        -- one_index: { { key1 = 1}, { key2 = 1 },  unique = true }
        { { id = "hashed" }, unique = true },
        { { account = 1 }, { time = -1 } }
    }
}

return indexes
