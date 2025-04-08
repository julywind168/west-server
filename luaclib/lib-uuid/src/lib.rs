use mlua::prelude::*;
use uuid::Uuid;

fn v4(_: &Lua, _: ()) -> LuaResult<String> {
    Ok(Uuid::new_v4().to_string())
}

fn v7(_: &Lua, _: ()) -> LuaResult<String> {
    Ok(Uuid::new_v7(uuid::Timestamp::now(uuid::NoContext)).to_string())
}

#[mlua::lua_module]
fn uuid(lua: &Lua) -> LuaResult<LuaTable> {
    let exports = lua.create_table()?;
    exports.set("v4", lua.create_function(v4)?)?;
    exports.set("v7", lua.create_function(v7)?)?;
    Ok(exports)
}
