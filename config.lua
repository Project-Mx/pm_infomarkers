Config = {}

Config.Locale = 'en'

Config.UsePostalFeature = true

Config.MarkerLimit = 5 

Config.AdminGroups = {
    'admin',
    'superadmin'
}

Config.WhitelistJobs = {
    'police',
    'ambulance',
    'mechanic'
}

Config.DefaultDistance = 5

Config.Locales = {
    ['en'] = {
        ['info_message'] = "^4[INFO]:^0",
        ['phone_display'] = "^3[%s]^2[PH:%s] ^0%s.",
        ['marker_created'] = 'Info marker created.',
        ['marker_deleted'] = 'Info marker deleted.',
        ['invalid_marker'] = 'Invalid marker index.',
        ['marker_limit'] = 'Marker limit reached. You cannot add more markers.',
        ['postal_not_found'] = 'Postal code not found.',
        ['usage'] = 'Usage: /infom [PHONE] [POSTAL] [TEXT]',
        ['no_permission'] = 'You do not have permission to use this command.'
    }
}
