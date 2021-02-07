pastebin_login = function(api_dev_key, api_user_name, api_user_password) {

	require(RCurl)

	response = as.character(postForm(
		uri = 'http://pastebin.com/api/api_login.php',
		api_dev_key = api_dev_key,
		api_user_name = api_user_name,
		api_user_password = api_user_password
	))

	if (length(grep("Bad API request", response)) > 0) stop(response)

	return(response)
}

pastebin_paste = function(api_dev_key, api_user_key, api_paste_code, api_paste_name, api_paste_format,
    api_paste_private = c('0', '1', '2'), api_paste_expire_date = c('N','10M','1H','1D','1W','2W','1M')) {

	require(RCurl)

	response = as.character(postForm(
		uri = 'http://pastebin.com/api/api_post.php',
		api_option = 'paste',
		api_dev_key = api_dev_key,
		api_paste_code = api_paste_code,
		api_paste_private = api_paste_private,
		api_paste_name = api_paste_name,
		api_paste_expire_date = api_paste_expire_date,
		api_paste_format = api_paste_format,
		api_user_key = api_user_key
	))

	if (length(grep("Bad API request", response)) > 0) stop(response)
	
	paste_key = gsub('http://pastebin.com/', '', response)

	return(paste_key)
}

pastebin_list = function(api_dev_key, api_user_key, api_results_limit = 50) {

	require(RCurl)

	response = as.character(postForm(
		uri = 'http://pastebin.com/api/api_post.php',
		api_option = 'list',
		api_dev_key = api_dev_key,
		api_results_limit = api_results_limit,
		api_user_key = api_user_key
	))
	
	if (length(grep("Bad API request", response)) > 0) stop(response)

	return(response)
}

pastebin_delete = function(api_dev_key, api_user_key, api_paste_key) {

	require(RCurl)

	response = as.character(postForm(
		uri = 'http://pastebin.com/api/api_post.php',
		api_option = 'delete',
		api_dev_key = api_dev_key,
		api_paste_key = api_paste_key,
		api_user_key = api_user_key
	))
	
	if (length(grep("Bad API request", response)) > 0) stop(response)

	return(response)
}

pastebin_trends = function(api_dev_key) {

	require(RCurl)

	response = as.character(postForm(
		uri = 'http://pastebin.com/api/api_post.php',
		api_option = 'trends',
		api_dev_key = api_dev_key
	))

	if (length(grep("Bad API request", response)) > 0) stop(response)

	return(response)
}

pastebin_userdetails = function(api_dev_key, api_user_key) {

	require(RCurl)

	response = as.character(postForm(
		uri = 'http://pastebin.com/api/api_post.php',
		api_option = 'userdetails',
		api_dev_key = api_dev_key,
		api_user_key = api_user_key
	))
	
	if (length(grep("Bad API request", response)) > 0) stop(response)
	
	return(response)
}

pastebin_get = function(paste_key) {

	require(RCurl)

	raw = getURL(paste('http://pastebin.com/raw.php?i=', paste_key, sep = ""))
	
	return(raw)
}
