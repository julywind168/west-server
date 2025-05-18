local function worker_service(name, id)
    local skynet = require "skynet"
    local mongo = require "skynet.db.mongo"
    local conf = require(string.format("config.mongo-%s", name))

    local client, db

    local function init_indexes()
        local indexes = require(string.format("config.mongo-%s-indexes", name))
        if type(indexes) ~= "table" then
            skynet.error(("you mabye forget to create config/mongo-%s-indexes.lua!"):format(name))
            return
        end
        for coll, idxs in pairs(indexes) do
            for i, idx in ipairs(idxs) do
                db[coll]:createIndex(idx)
            end
        end
    end

    local array_mt = {}

    function array_mt:__len()
        return rawlen(self)
    end

    local function normalize(doc)
        for key, value in pairs(doc) do
            if type(value) == "table" then
                doc[key] = normalize(value)
            end
        end
        if doc.__array then
            doc.__array = nil
            return setmetatable(doc, array_mt)
        else
            return doc
        end
    end


    local function init()
        client = mongo.client(conf.conf)
        db = client[conf.db_name]
        if id == 1 then
            init_indexes()
        end
    end

    local command = {}

    function command.insert_one(coll, doc)
        return db[coll]:safe_insert(normalize(doc))
    end

    function command.insert_many(coll, docs)
        return db[coll]:safe_batch_insert(normalize(docs))
    end

    function command.delete_one(coll, query)
        return db[coll]:delete(query, 1)
    end

    function command.delete_many(coll, query)
        return db[coll]:delete(query)
    end

    function command.find_one(coll, query, projection)
        return db[coll]:findOne(query, projection)
    end

    function command.find_many(coll, query, projection, sorter, limit, skip)
        local t = {}
        local it = db[coll]:find(query, projection)
        if not it then
            return t
        end

        if sorter then
            if #sorter > 0 then
                it = it:sort(table.unpack(sorter))
            else
                it = it:sort(sorter)
            end
        end

        if limit then
            it:limit(limit)
        end

        if skip then
            it:skip(skip)
        end

        while it:hasNext() do
            table.insert(t, it:next())
        end

        return t
    end

    function command.update_one(coll, query, update)
        return db[coll]:safe_update(query, update)
    end

    function command.update_many(coll, query, update)
        return db[coll]:safe_update(query, update, false, true)
    end

    function command.count(coll, query)
        return db[coll]:find(query):count()
    end

    -- Index
    function command.create_index(coll, ...)
        return db[coll]:createIndex(...)
    end

    function command.drop_index(coll, ...)
        return db[coll]:dropIndex(...)
    end

    -- Ex
    function command.set(coll, query, fields)
        return db[coll]:safe_update(query, { ["$set"] = fields })
    end

    function command.upsert(coll, query, fields)
        return db[coll]:safe_update(query, { ["$set"] = fields }, true, false)
    end

    function command.sum(coll, query, key)
        local pipeline = {}
        if query then
            table.insert(pipeline, { ["$match"] = query })
        end

        table.insert(pipeline, { ["$group"] = { _id = false, [key] = { ["$sum"] = "$" .. key } } })

        local result = db:runCommand("aggregate", coll, "pipeline", pipeline, "cursor", {}, "allowDiskUse", true)

        if result and result.ok == 1 then
            if result.cursor and result.cursor.firstBatch then
                local r = result.cursor.firstBatch[1]
                return r and r[key] or 0
            end
        end
        return 0
    end

    skynet.start(function()
        skynet.dispatch("lua", function(session, source, cmd, ...)
            local f = command[cmd]
            skynet.ret(skynet.pack(f(...)))
        end)
        init()
    end)
end

return worker_service
