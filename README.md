# Forumlancer

**Forumlancer** is a Discord bot that provides notifications for activity on the [DiscoveryGC forums](https://discoverygc.com/forums/portal.php).

### Purpose

The forum is an integral part of Discovery Freelancer. Despite this, it is often  difficult or frustrating for members to stay abreast of activity relevant to them. The forum search function has a minimum query length of 4 characters - useless for the many player factions that go by three-letter abbreviations.

Forumlancer allows you to automatically subscribe to threads whose titles contain terms you are interested in and receive notifications of their activity in your Discord server.


### How to use it

~~Add **Forumlancer#5256** to your server using this link.~~ Currently in closed beta.

Optionally, you can create a role for Forumlancer to constrain it to the channel you want to use for notifications. The bot must be able to send messages and embeds.

The bot will accept commands prefaced with `f/` - to get started, use `f/help`. The basic commands are:

- `help` - show a help message. Run `help <command>` to see help about that command
- `init` - configure the bot to use this channel for notifications
- `watch <term>` - get notifications for threads with titles including this term
- `unwatch <term>` - no longer get notifications for threads including this term
- `watchlist` - show the current watchlist
- `exclude <profile_url>` - exclude a forum account (such as your own) from causing notifications
- `include <profile_url>` - no longer exclude a forum account from causing notifications
- `excluded` - show excluded forum accounts
- `info` - show information about the bot

As a bonus/Easter egg/irritation, Forumlancer will also respond to many Skype emoticon names - e.g. "(bandit)" - so you can reminisce about the good old days.


### How it works

Rather than scraping the entire contents of the site, Forumlancer periodically scans the "latest threads" sidebar on the forum [homepage](https://discoverygc.com/forums/portal.php). I chose this method because it's [quick and easy](https://youtu.be/HjVRLxMeoUk), but also out of consideration for the number of requests made to the web server. An [RSS feed](https://discoverygc.com/forums/syndication.php) for the forum exists, and this would be best of all if not for its posts lagging the actual forum activity by a few hours for some reason.

Forumlancer is written in Ruby and uses the excellent [Discordrb](https://github.com/discordrb/discordrb), [Nokogiri](https://github.com/sparklemotion/nokogiri) and [rufus-scheduler](https://github.com/jmettraux/rufus-scheduler). All of Forumlancer's code is licensed under the [GNU AGPL-3.0](https://www.gnu.org/licenses/agpl-3.0.en.html).


### Hosting

I currently run Forumlancer on a Raspberry Pi 4. To host it yourself,

 - [create a bot user](https://discord.com/developers/applications)
 - set the environment variable `TOKEN` to your bot's token
 - set the environment variable `CLIENT` to your application's client ID
 - run `bundle exec ruby src/forumlancer.rb` to start the bot
