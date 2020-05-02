# Description
#   Comes up with inspiring project ideas
#
# Inspirations:
#   - https://github.com/fcingolani/hubot-game-idea
#   - https://github.com/ashotduder/Idea-Generator
#   - https://github.com/poshaughnessy/future-tech-idea-generator
#   - https://shop.nearfuturelaboratory.com/collections/design-fiction-tools/products/design-fiction-product-design-work-kit
#
# Dependencies:
#   "lodash.js"
#
# Commands:
#   hubot clue me in - Generate a random idea
#
# Author:
#   sodacpr <ol@utou.ch>

_ = require 'lodash'

module.exports = (robot) ->
  # Load the ideas data
  hackyIdeas = require process.cwd() + '/hacky-ideas.json'
  hackyObjects = _.shuffle hackyIdeas.object
  hackySubjects = _.shuffle hackyIdeas.subject
  hackyPredicates = _.shuffle hackyIdeas.predicate

  robot.respond /clue( me)?( in)?/i, (res) ->
    if hackyObjects.length == 0 or
       hackySubjects.length == 0 or
       hackyPredicates.length == 0
      res.send ":sob: I'm all out of ideas! Just go save the planet."
    object = hackyObjects.pop()
    subject = hackySubjects.pop()
    predicate = hackyPredicates.pop()
    intro = ":stars: You should make"
    res.send(
      attachments: [
        {
          text: "#{intro} *#{object}* that #{predicate} *#{subject}*"
          fallback: "#{intro} #{object} that #{predicate} #{subject}"
          mrkdwn_in: ['text']
          color: 'warning'
        }
      ]
    )
    return
