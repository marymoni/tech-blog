lj_auth = function(user_name, password_hash) {

	require(httr)
	require(XML)
	require(digest)

	getchallenge_xml_rpc = '<?xml version="1.0"?>
		<methodCall>
			<methodName>LJ.XMLRPC.getchallenge</methodName>
			<params>
				<param>
					<value><struct></struct></value>
				</param>
			</params>
		</methodCall>
	'

	challenge_response = POST(
		"http://www.livejournal.com/interface/xmlrpc",
		accept_xml(),
		add_headers("Content-Type" = "text/xml"),
		body = getchallenge_xml_rpc
	)

	challenge = xpathApply(xmlInternalTreeParse(content(challenge_response)), '//member[name="challenge"]/value/string', xmlValue)[[1]]

	response = digest(paste(challenge, password_hash, sep = ""), "md5", serialize = F)

	return(list(challenge = challenge, response = response))
}

lj_list = function(use_journal, user_name, password_hash, show_progress = T) {

	require(httr)
	require(XML)
	require(data.table)

	entries = data.table(itemid = integer(0), subject = character(0), url = character(0), reply_count = integer(0), eventtime = character(0))

	last_sync = ""
	
	if (show_progress) cat("start reading...\n")
	
	repeat {

		auth = lj_auth(user_name, password_hash)

		xml_rpc = sprintf('<?xml version="1.0"?>
			<methodCall>
				<methodName>LJ.XMLRPC.getevents</methodName>
				<params>
					<param>
						<value>
							<struct>
								<member><name>username</name><value><string>%s</string></value></member>
								<member><name>auth_method</name><value><string>challenge</string></value></member>
								<member><name>auth_challenge</name><value><string>%s</string></value></member>
                                <member><name>auth_response</name><value><string>%s</string></value></member>
								<member><name>ver</name><value><int>1</int></value></member>
								<member><name>truncate</name><value><int>50</int></value></member>
								<member><name>selecttype</name><value><string>syncitems</string></value></member>
								<member><name>howmany</name><value><int>200</int></value></member>
								<member><name>noprops</name><value><boolean>1</boolean></value></member>
								<member><name>lineendings</name><value><string>unix</string></value></member>
								<member><name>usejournal</name><value><string>%s</string></value></member>
								<member><name>lastsync</name><value><string>%s</string></value></member>
							</struct>
						</value>
					</param>
				</params>
			</methodCall>', user_name, auth$challenge, auth$response, use_journal, last_sync
		)

		response = POST(
			"http://www.livejournal.com/interface/xmlrpc",
			accept_xml(),
			add_headers("Content-Type" = "text/xml"),
			add_headers(Range = 'bytes=-500000'),
			httr::config(accept_encoding="identity"),
			body = xml_rpc,
			encode = "form"
		)

		xdoc = xmlInternalTreeParse(content(response))
		
		itemid = as.integer(xpathApply(xdoc, '//member[name="ditemid"]/value/int', xmlValue))
		subject = as.character(xpathApply(xdoc, '//member[name="subject"]/value', xmlValue))
		reply_count = as.integer(xpathApply(xdoc, '//member[name="reply_count"]/value/int', xmlValue))
		url = as.character(xpathApply(xdoc, '//member[name="url"]/value/string', xmlValue))
		eventtime = as.character(xpathApply(xdoc, '//member[name="eventtime"]/value/string', xmlValue))

		if (length(url) == 0) break
		
		last_sync = as.character(as.POSIXct(max(eventtime)) + 1)
		if (show_progress) cat("read entries", length(url), "last sync time", last_sync, "\n")

		entries = rbind(entries, data.table(itemid = itemid, subject = subject, url = url, reply_count = reply_count, eventtime = eventtime))
        
        Sys.sleep(3)
	}

	return(entries)
}

lj_entry = function(use_journal, itemid) {

	require(httr)
	require(XML)

	url = sprintf("http://%s.livejournal.com/data/rss/?itemid=%d", use_journal, itemid)
	response = GET(url)

	text = xpathApply(content(response), "//item/description", xmlValue)
	if (length(text) == 0) return("")

	return(text[[1]])
}
