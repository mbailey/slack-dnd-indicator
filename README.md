# slack-dnd-indicator

Proof of concept for Slack Busylight

As someone who loves helping people at work but also needs focus time,  
I want a little light on my monitor that indicates whether I'm available.

And I want it to change color when I update my Snooze Notifications on Slack.

![blink(1)](blink1mk2-gooseneck.jpg)

## What's done already?

A throwaway script that:
- connects to Slack using the [Legacy Tokens][legacy-tokens] they advise against using
- reads current Snooze status
- listens on a websocket for updates to Snooze Status


[legacy-tokens]: https://api.slack.com/custom-integrations/legacy-tokens
