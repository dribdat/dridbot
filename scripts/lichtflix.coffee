# Description
#   Suggests a movie from an online database
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot flix
#
# Notes:
#   None
#
# Author:
#   loleg <loleg@hotmail.com>

Papa = require 'papaparse'

module.exports = (robot) ->
  robot.respond /(flix)/i, (msg) ->
    msg.http("https://raw.githubusercontent.com/schoolofdata-ch/lichtspiel-films/master/data/sample.csv")
      .header('Accept', 'application/csv')
      .get() (err, res, body) ->
        films = Papa.parse body, { header: true }
        item = films.data[Math.floor Math.random() * films.data.length]
        # console.log(item)
        msg.send(
          attachments: [
            {
              text: "**#{item.title}** (#{item.year})\n> #{item.text_en}\n![](http://xray876.server4you.net/archiv.lichtspiel/getObject.aspx?objID=2007)"
              fallback: "#{item.title} (#{item.year})"
              mrkdwn_in: ['text']
            }
          ]
        )
    return
