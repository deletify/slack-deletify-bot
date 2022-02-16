# slack-deletify-bot

- Watch my YouTube video to setup deletifybot with Slack https://bit.ly/2ZMwOVG.
- Use this command to deploy your stuff on staging via slack `deploy node-api master to stg`.

```sh
# to install
sudo apt install -y ruby ruby-bundler ruby-dev build-essential ruby-build

# install bundle for deletifybot
bundle install --path vendor/bundle

# run deletifybot
SLACK_API_TOKEN=YOUR_BOT_TOKEN bundle exec ruby deploy.rb
```
