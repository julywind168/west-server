use mlua::prelude::*;

fn encode(_: &Lua, (value, pretty): (LuaValue, bool)) -> LuaResult<String> {
    match pretty {
        true => Ok(serde_json::to_string_pretty(&value).map_err(LuaError::external)?),
        false => Ok(serde_json::to_string(&value).map_err(LuaError::external)?),
    }
}

fn decode(lua: &Lua, json: String) -> LuaResult<LuaValue> {
    let val: serde_json::Value = serde_json::from_str(&json).map_err(LuaError::external)?;
    Ok(lua.to_value(&val).map_err(LuaError::external)?)
}

#[mlua::lua_module]
fn json(lua: &Lua) -> LuaResult<LuaTable> {
    let exports = lua.create_table()?;
    exports.set("encode", lua.create_function(encode)?)?;
    exports.set("decode", lua.create_function(decode)?)?;
    Ok(exports)
}
