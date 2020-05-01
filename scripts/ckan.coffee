# Description:
#   Commands to query CKAN portals for open data
#
# Dependencies:
#   "ckan.js"
#
# Commands:
#   hubot fresh data - Get the latest open datasets
#   hubot data on <subject> - Query datasets for a subject

CKAN = require 'ckan'
logdev = require('tracer').colorConsole()

clients = []

# Yes, hard coding is a Bad Thing...
clients.push new CKAN.Client "https://opendata.swiss/en"
clients.push new CKAN.Client "https://data.stadt-zuerich.ch"
clients[1].requestType = 'GET'

NUM_RESULTS = 3
DATA_REQUEST = "Please make a request in the #data channel!"
# ...and it should go into a .json or .yml file. We know.

module.exports = (robot) ->

	robot.respond /(fresh )?(data)( on)?(.*)/i, (res) ->
		query = res.match[res.match.length-1].trim()

		if query is ""
			data = { sort: 'metadata_modified desc' }
			res.reply "Fetching fresh, open data..."
		else if query is "request"
			res.reply DATA_REQUEST
			return
		else
			data = { q: query }
			res.reply "Looking up open '#{query}' data..."

		getDsTitle = (title) ->
			title.en || title.de || title.fr || title

		shown = total = 0
		queryPortal = (client) ->
			if not client or not client.endpoint
				logdev.warn "No endpoint provided"
				return
			logdev.info "#{client.endpoint}"
			portal = client.endpoint.split('//')[1]
			portalname = portal.split('/')[0]
			portalurl = "https://" + portal.replace('/api','') + "/dataset/"
			action = "package_search"
			client.action action, data, (err, json) ->
				shownhere = 0
				if err
					logdev.error "Service error"
					logdev.debug "#{err}"
				else if !json.success
					if json.error
						logdev.warn "#{json.error.message}"
					else
						logdev.error "#{json}"
				else
					if json.result.count > 0
						datasets = json.result.results
						total += json.result.count
						shownhere = Math.min(datasets.length, NUM_RESULTS)
						shown += shownhere
						latest = (
							"> #{getDsTitle(ds.title)} - " + portalurl +
							"#{ds.name}" for ds in datasets
							)
						latest = latest[0..shownhere-1].join '\n'
						if shownhere
							res.send "*#{portalname}*\n#{latest}"
				if shown < 10
					if ++curClient < clients.length
						queryPortal clients[curClient]
					else if not shown
						res.send "Nothing found on that topic - say *data request* for help."
				else if shown < total
					res.send "(#{shown} shown from #{total})"

		curClient = 0
		queryPortal clients[0]
