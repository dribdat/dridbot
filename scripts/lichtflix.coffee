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
              text: "#{item.title} (#{item.year})\n_#{item.text_en}_"
              fallback: "#{item.title} (#{item.year})"
              mrkdwn_in: ['text']
            }
          ]
        )
        setTimeout () ->
          msg.send ":movie_camera: Enjoy this finest reel this evening only at the Lichtspiel!"
        , 1000 * 10
    return
