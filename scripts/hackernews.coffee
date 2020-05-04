# Description
#   Shows the top stories from Ycombinator Hacker News
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot hackernews - Get the top 5 items from Hacker News
#   hubot hn - A shorter form of the above
#
# Notes:
#   None
#
# Author:
#   WhoIsKevin <kbrown@whoiskevin.com>
#   loleg <loleg@hotmail.com> (fixed a bug, changed to showstories)

module.exports = (robot) ->
  robot.respond /(hn|hackernews)/i, (msg) ->
    msg.http("https://hacker-news.firebaseio.com/v0/showstories.json")
      .header('Accept', 'application/json')
      .get() (err, res, body) ->
        hnnewslist = JSON.parse body
        for i in [0..4]
          msg.http("https://hacker-news.firebaseio.com/v0/item/" + hnnewslist[i] + ".json")
            .header('Accept', 'application/json')
            .get() (err, res, itembody) ->
              hnnewsitem = JSON.parse itembody
              hnurl = "https://news.ycombinator.com/item?id=#{hnnewsitem.id}"
              msg.send "#{hnnewsitem.title} #{hnurl}"
              if hnnewsitem.url
                msg.send "#{hnnewsitem.url}"
    return
