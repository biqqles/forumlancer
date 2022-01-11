# Forumlancer

**Forumlancer** is a Discord bot that provides notifications for activity on the [DiscoveryGC forums](https://discoverygc.com/forums/portal.php).

### Purpose

The forum is an integral part of Discovery Freelancer. Despite this, it is often  difficult or frustrating for members to stay abreast of activity relevant to them. The forum search function has a minimum query length of 4 characters - useless for the many player factions that go by three-letter abbreviations.

Forumlancer allows you to automatically subscribe to threads whose titles contain terms you are interested in and receive notifications of their activity in your Discord server.


### How to use it

[Add **Forumlancer#5256** to your server using this link.](https://discord.com/api/oauth2/authorize?client_id=713391469515243560&permissions=0&scope=bot)

Optionally, you can create a role for Forumlancer to constrain it to the channel you want to use for notifications. The bot must be able to send messages and embeds.

The bot will accept commands prefaced with `f/` - to get started, use `f/help`. The basic commands are:

- `help` - show a help message. Run `help <command>` to see help about that command
- `init` - configure the bot to use this channel for notifications
- `watch <term>` - get notifications for threads with titles including this term
- `unwatch <term>` - no longer get notifications for threads including this term
- `watchlist` - show the current watchlist
- `ignore <profile_url>` - exclude a forum account (such as your own) from causing notifications
- `unignore <profile_url>` - no longer exclude a forum account from causing notifications
- `ignored` - show ignored forum accounts
- `info` - show information about the bot

As a bonus/Easter egg/irritation, Forumlancer will also respond to many Skype emoticon names - e.g. "(bandit)" - so you can reminisce about the good old days.


### How it works

Rather than scraping the entire contents of the site, Forumlancer periodically scans the "latest threads" sidebar on the forum [homepage](https://discoverygc.com/forums/portal.php). I chose this method because it's [quick and easy](https://youtu.be/HjVRLxMeoUk), but also out of consideration for the number of requests made to the web server. An [RSS feed](https://discoverygc.com/forums/syndication.php) for the forum exists, and this would be best of all if not for its posts lagging the actual forum activity by a few hours for some reason.

Forumlancer is written in Ruby and uses the excellent [discordrb](https://github.com/shardlab/discordrb), [Oga](https://gitlab.com/yorickpeterse/oga) and [rufus-scheduler](https://github.com/jmettraux/rufus-scheduler), as well as my own library [geode](https://github.com/biqqles/geode). All of Forumlancer's code is licensed under the [GNU AGPL-3.0](https://www.gnu.org/licenses/agpl-3.0.en.html).


### Hosting

I currently host Forumlancer (for free) on Heroku. To run it yourself,

 1. [create a bot user](https://discord.com/developers/applications)
    - set the environment variable `TOKEN` to your bot's token
    - set the environment variable `CLIENT` to your application's client ID
 2. [start `postgres`](https://www.postgresql.org/docs/current/server-start.html)
 3. run `bundle exec ruby src/forumlancer.rb` to start the bot.
