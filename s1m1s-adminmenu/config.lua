Config = {}

Config.CommandGroups = {
    amenu = { 'superadmin', 'admin', 'mod' },
}

Config.SuperAccessGroups = { 'superadmin', 'admin' }

Config.GroupRoleMap = {
    superadmin = 'owner',
    admin = 'admin',
    mod = 'vyrsupport'
}

Config.ValidRoles = {
    owner = true, dev = true, pagradmin = true, vyradmin = true,
    admin = true, vyrsupport = true, support = true, player = true
}

return Config