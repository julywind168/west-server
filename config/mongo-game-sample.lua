-- This is a sample configuration file for MongoDB.
-- new a file eg: `mongo-game.lua` in the same directory and copy this content to it.

return {
	db_name = "game",
	conf = {
		host = "127.0.0.1",
		port = 27017,
		authdb = "admin",
		username = "USERNAME",
		password = "PASSWORD",
	}
}