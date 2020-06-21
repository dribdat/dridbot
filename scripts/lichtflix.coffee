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
Conversation = require 'hubot-conversation'

films = null
movie_types = ["Dokumentar", "Trickfilm", "Scopitone", "Spielfilm",
"Trailer", "Fragment", "Amateur", "Werbung", "Wochenschau", "Slapstick",
"Musikclip", "Experimentalfilm", "Testfilm", "Tonband", "TV"]
lichtspiel_url = "https://raw.githubusercontent.com/schoolofdata-ch/lichtspiel-films/master/data/lichtspiel.csv"

fetch_films = (msg) ->
    (func) ->
        msg.http(lichtspiel_url)
          .header('Accept', 'application/csv')
          .get() (err, res, body) ->
            films = Papa.parse body, { header: true }
            func msg

default_type = "dummy"
default_date = -1

movie_type = default_type
max_date = default_date

reset_variables = () ->
    movie_type = default_type
    max_date = default_date

send_attachment = (msg, item) ->
    msg.send(
      attachments: [
        {
          text: "#{item.title} (#{item.year})\n_#{item.text_en}_"
          fallback: "#{item.title} (#{item.year})"
          mrkdwn_in: ['text']
        }
      ]
    )

flix = (msg) ->
    if films is null
        (fetch_films msg) ((msg) -> flix msg)
        return

    item = films.data[Math.floor Math.random() * films.data.length]
    console.log(item)
    send_attachment msg, item

recommend = (msg) ->
    if films is null
        (fetch_films msg) ((msg) -> recommend msg)
        return

    filtered_films = films.data

    if movie_type != default_type
        filtered_films = filtered_films.filter((item) -> item.type == movie_type)

    if max_date != default_date
        filtered_films = filtered_films.filter((item) -> parseInt(item.year) < max_date)

    if filtered_films.length > 0
        recommendation = filtered_films[Math.floor Math.random() * filtered_films.length]
        msg.send "I can recommend \"#{recommendation.title}\"\n"

        # some dates are NaN or have typos/strange values
        if recommendation.year > 1200
            msg.send "It came out in #{recommendation.year}\n"

        if recommendation.text_en.length > 0
            msg.send "Here's a short description: "
            msg.send "#{recommendation.text_en}"
    else
        msg.send "I actually don't have any information on movies that match this description"

    reset_variables()


pick_production_date = (msg, dialog) ->
    msg.send "Pick a date for the latest year of production\n
              (I want a movie made before 1980, for example)"

    dialog.addChoice /(18|19|20)([0-9]{2})/, (res) ->
        max_date = parseInt(res.match[0])
        msg.send "And you want a movie made before #{max_date}"
        recommend msg

    dialog.addChoice "(.*)", (res) ->
        msg.reply "I don't know of any movies made before #{res.match[0]}"
        pick_production_date msg, dialog

pick_movie_type = (msg, dialog) ->
    msg.send "From these choices, what type of movie would you like to see?"
    msg.send "#{movie_types.join(', ')}"

    dialog.addChoice "#{movie_types.join('|')}", (res) ->
        movie_type = res.match[0]
        msg.send "Okay, you want to watch a #{movie_type}"
        pick_production_date msg, dialog

    dialog.addChoice "(.*)", (res) ->
        msg.reply "Hmmm, try another type. I don't know about \"#{res.match[0]}\""
        pick_movie_type msg, dialog

start_recommendation = (switchboard, msg) ->
    if films is null
        (fetch_films msg) ((msg) -> start_recommendation switchboard, msg)
        return

    dialog = switchboard.startDialog msg
    pick_movie_type msg, dialog

module.exports = (robot) ->

  switchboard = new Conversation robot

  robot.respond /(I'm|I am) (looking|searching) for a movie( recommendation|.*)/i, (msg) ->
    msg.send "Great, I'll ask a few questions to determine a recommendation"
    start_recommendation switchboard, msg

  robot.respond /I (want|would like) to watch a (.*)/i, (msg) ->

    movie_type = msg.match[2]
    if movie_type in movie_types
        msg.reply "So, you want to watch a #{movie_type}?\n"

        recommend msg

    else
        msg.reply "Sorry, I'm not familiar with \"#{movie_type}\""
        msg.reply "I am familiar with #{movie_types.join(', ')}"

    reset_variables()

  robot.respond /(flix)/i, (msg) ->

        flix msg

        setTimeout () ->
          msg.send ":movie_camera: Enjoy this finest reel this evening only at the Lichtspiel!"
        , 1000 * 10
    return
