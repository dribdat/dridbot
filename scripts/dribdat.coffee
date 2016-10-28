# Description:
#   Commands that interface with Dribdat
#
# Dependencies:
#
# Commands:
#   hubot time left - How much time until the hackathon starts or finishes?
#   hubot top projects - Show the most active projects at the hackathon.
#   hubot find <query> - Search among the current hackathon projects.
#   hubot start project - Get help starting a project

logger = require('tracer').dailyfile(
  root: '.'
  maxLogFiles: 5)

module.exports = (robot) ->

  DRIBDAT_URL = "http://dribdat.soda.camp"

  timequotes = [
    'History is a relentless master. It has no present, only the past rushing into the future. To try to hold fast is to be swept aside. -John F. Kennedy',
    'A kitten is chiefly remarkable for rushing about like mad at nothing whatever, and generally stopping before it gets there. -Agnes Repplier',
    'The great fun in my life has been getting up every morning and rushing to the typewriter because some new idea has hit me. -Ray Bradbury',
    'Rushing the ball is all about ball control. If you run the ball, you control the clock. If you control the clock, you usually control the game. -Tiki Barber',
    'The environmental crisis is all a result of rushing. -Ed Begley, Jr.'
  ]

  robot.hear /(.*)/, (res) ->
    query = res.match[0]
    logger.trace "#{query} [##{res.message.room}]"

  robot.respond /time( left)?\??/i, (res) ->
    robot.http(DRIBDAT_URL + "/api/event/current/info.json")
    .header('Accept', 'application/json')
    .get() (err, response, body) ->
      # error checking code here
      data = JSON.parse body
      quote = res.random timequotes
      if data.timeuntil
        res.send "> #{quote}\n\nThere is still #{data.timeuntil} for #{data.event.name}"
      else
        res.send "#{data.event.name} is over. Hack again soon!"

  robot.respond /top( projects)?/i, (res) ->
    robot.http(DRIBDAT_URL + "/api/event/current/projects.json")
    .header('Accept', 'application/json')
    .get() (err, response, body) ->
      # error checking code here
      data = JSON.parse body
      if data.projects.length == 0
        res.send "No projects to speak of. Have we even started yet? :stuck_out_tongue_closed_eyes:"
      else
        pcount = data.projects.length + 1
        for project, ix in data.projects[0..2]
          res.send "#{ix + 1}. #{project.name} (#{project.score})"
        res.send ":crown: To see all #{pcount} projects, visit #{DRIBDAT_URL}"

  robot.respond /find( a)?( project)?(.*)/i, (res) ->
    query = res.match[res.match.length-1].trim()
    if query is ""
      res.send "Looking for something to work on..? :stuck_out_tongue_closed_eyes:"
      return
    robot.http(DRIBDAT_URL + "/api/project/search.json?q=" + query)
    .header('Accept', 'application/json')
    .get() (err, response, body) ->
      # error checking code here
      data = JSON.parse body
      if data.projects.length == 0
        res.send ":wind_blowing_face: Nothing found. Why not make your own #{query}?"
      else
        res.send "Here are #{data.projects.length} matches:"
        for project in data.projects
          res.send "*#{project.name}*: #{project.summary} #{DRIBDAT_URL}/project/#{project.id}"

  hasPicked = false
  robot.respond /start( project)?(.*)/i, (res) ->
    query = res.match[res.match.length-1].trim()
    if query is ""
      res.send "So you want to start a new project? Great! First you need to pick a name with your team. Say START followed by a name."
      setTimeout () ->
          return if hasPicked
          res.send "Having trouble finding a name? Try http://www.ykombinator.com/"
          setTimeout () ->
              return if hasPicked
              res.send "Maybe that was not so helpful :laughing: Try this instead: http://www.namemesh.com/company-name-generator/"
            , 1000 * 30
        , 1000 * 5
      return
    hasPicked = true
    teamname = query.toLowerCase().replace(/[^A-z0-9]/g, "-")
    res.send "Great! If you have not already, you should now start a channel with the same name, and invite your team members to ##{teamname}"