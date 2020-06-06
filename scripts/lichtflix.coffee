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

films = null
movie_types = ["Dokumentar", "Trickfilm", "Scopitone", "Spielfilm",
"Trailer", "Fragment", "Amateur", "Werbung", "Wochenschau", "Slapstick",
"Musikclip", "Experimentalfilm", "Testfilm", "Tonband", "TV"]
lichtspiel_url = "https://raw.githubusercontent.com/schoolofdata-ch/lichtspiel-films/master/data/lichtspiel.csv"

recommend = (movie_type, msg) ->
    filtered_films = films.data.filter((item) -> item.type == movie_type)
    recommendation = filtered_films[Math.floor Math.random() * filtered_films.length]

    msg.send "I can recommend \"#{recommendation.title}\"\n"
    if recommendation.text_en.length > 0
        msg.send "Here's a short description: "
        msg.send "#{recommendation.text_en}"

send_attachment = (item, msg) ->
    msg.send(
      attachments: [
        {
          text: "#{item.title} (#{item.year})\n_#{item.text_en}_"
          fallback: "#{item.title} (#{item.year})"
          mrkdwn_in: ['text']
        }
      ]
    )

module.exports = (robot) ->
  robot.respond /I want to watch a (.*)/i, (msg) ->

  robot.respond /I (want|would like) to watch a (.*)/i, (msg) ->

    movie_type = msg.match[2]
    if movie_type in movie_types
        msg.reply "So, you want to watch a #{movie_type}?\n"

        # Fetch the data if it hasn't been fetched yet
        if films is null
            msg.http(lichtspiel_url)
              .header('Accept', 'application/csv')
              .get() (err, res, body) ->
                films = Papa.parse body, { header: true }
                recommend movie_type, msg
        else
            recommend movie_type, msg

    else
        msg.reply "Sorry, I'm not familiar with \"#{movie_type}\""
        msg.reply "I am familiar with #{movie_types.join(', ')}"

  robot.respond /(flix)/i, (msg) ->
        if films is null
            msg.http(lichtspiel_url)
              .header('Accept', 'application/csv')
              .get() (err, res, body) ->
                films = Papa.parse body, { header: true }

                item = films.data[Math.floor Math.random() * films.data.length]
                console.log(item)
                send_attachment item, msg
        else
            item = films.data[Math.floor Math.random() * films.data.length]
            console.log(item)
            send_attachment item, msg

        setTimeout () ->
          msg.send ":movie_camera: Enjoy this finest reel this evening only at the Lichtspiel!"
        , 1000 * 10
    return
