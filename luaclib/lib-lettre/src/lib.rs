use lettre::message::header::ContentType;
use lettre::transport::smtp::authentication::Credentials;
use lettre::{Message, SmtpTransport, Transport};
use mlua::prelude::*;

struct LuaMailer {
    mailer: SmtpTransport,
}

impl LuaUserData for LuaMailer {
    fn add_methods<M: mlua::UserDataMethods<Self>>(methods: &mut M) {
        methods.add_method("send_text", |_, this, params: LuaTable| {
            let from: String = params.get("from").map_err(LuaError::external)?;
            let reply_to: Option<String> = params.get("reply_to").ok();
            let to: String = params.get("to").map_err(LuaError::external)?;
            let subject: String = params.get("subject").map_err(LuaError::external)?;
            let body: String = params.get("body").map_err(LuaError::external)?;

            let mut email_builder = Message::builder()
                .from(from.parse().map_err(LuaError::external)?)
                .to(to.parse().map_err(LuaError::external)?)
                .subject(subject)
                .header(ContentType::TEXT_PLAIN);

            if let Some(reply_to) = reply_to {
                email_builder = email_builder.reply_to(
                    reply_to.parse().map_err(LuaError::external)?,
                );
            }

            let email = email_builder
                .body(body)
                .map_err(LuaError::external)?;

            this.mailer.send(&email).map_err(LuaError::external)?;
            Ok(())
        });
    }
}

fn mailer(_: &Lua, (server, username, password): (String, String, String)) -> LuaResult<LuaMailer> {
    let creds = Credentials::new(username, password);
    let mailer = SmtpTransport::relay(&server)
        .map_err(LuaError::external)?
        .credentials(creds)
        .build();
    Ok(LuaMailer { mailer })
}

#[mlua::lua_module]
fn lettre(lua: &Lua) -> LuaResult<LuaTable> {
    let exports = lua.create_table()?;
    exports.set("mailer", lua.create_function(mailer)?)?;
    Ok(exports)
}
