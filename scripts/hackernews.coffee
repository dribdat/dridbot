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
#
#
# Notes:
#   None
#
# Author:
#   WhoIsKevin <kbrown@whoiskevin.com>

module.exports = (robot) ->
  robot.respond /hackernews/i, (msg) ->
    msg.send "Here are the latest news headlines:"

    msg.http("https://hacker-news.firebaseio.com/v0/topstories.json")
      .header('Accept', 'application/json')
      .get() (err, res, body) ->
          hnnewslist = JSON.parse body
          for i in [0..4]
            msg.http("https://hacker-news.firebaseio.com/v0/item/" + hnnewslist[i] + ".json")
              .header('Accept', 'application/json')
              .get() (err, res, itembody) ->
                hnnewsitem = JSON.parse itembody
                hnurl = "https://news.ycombinator.com/item?id=#{hnnewsitem.id}"
                if hnnewsitem.url
                  msg.send "[#{hnnewsitem.title}](#{hnurl}) ([Article](#{hnnewsitem.url}))"
                else
                  msg.send "[#{hnnewsitem.title}](#{hnurl})"
    return
