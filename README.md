# slack-dnd-indicator

Proof of concept for Slack Busylight

As someone who loves helping people at work but also needs focus time,  
I want a little light on my monitor that indicates whether I'm available.

And I want it to change color when I update my Snooze Notifications on Slack.

![blink(1)](/images/blink1mk2-gooseneck.jpg)

## What's done already?

A throwaway script that:
- connects to Slack using the [Legacy Tokens][legacy-tokens] they advise against using
- reads [current Snooze status](https://api.slack.com/methods/dnd.info)
- listens to Slack's [RealTime Messaging API](https://api.slack.com/rtm) for updates to Snooze Status
- prints status to screen on startup and when it changes

## What's to be done?

Make this an accessible solution for everyone who might benefit!
- make it change the color of the blink(1) USB LED lights we've ordered (due 14 Nov via FEDEX)
- work out the best way to mount them (attach to monitor?)
- make it simple to install on Linux, MacOs, Windows


[blink](https://www.kickstarter.com/projects/thingm/blink1-the-usb-rgb-led)
[legacy-tokens]: https://api.slack.com/custom-integrations/legacy-tokens
