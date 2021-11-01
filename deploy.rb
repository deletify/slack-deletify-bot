require 'slack-ruby-bot'

class DeletifyBot < SlackRubyBot::Bot
  match(/deploy ((?<app>.+) (?<branch>.+)) (to) (?<env>.+)/i) do |client, data, match|
    org = "deletify"
    `rm -rf ~/#{match[:app]} && git clone https://github.com/#{org}/#{match[:app]}.git ~/#{match[:app]}`
    commit=`cd ~/#{match[:app]} && git ls-remote --heads origin #{match[:branch]} | awk '{print $1}'`.chomp

    if commit != ''
      short_commit=commit.slice(0..5)
      username = client.users[data.user][:name]
      client.say(text: "#{username} is deploying #{match[:app]}/#{match[:branch]} (#{short_commit}) to #{match[:env]}", channel: data.channel)

      if match[:app] && match[:branch] && match[:env]
        image="#{org}/#{match[:app]}:#{commit}".chomp
        is_image_valid=`docker pull #{image} >/dev/null 2>/dev/null && echo "success" || echo "failed"`.chomp

        if is_image_valid == 'success'
          #`docker pull #{image} >/dev/null 2>/dev/null`.chomp
          #`docker rm -f #{match[:app]} >/dev/null 2>/dev/null`.chomp
          #`docker rmi -f #{image} >/dev/null 2>/dev/null`.chomp
          #`docker run --name #{match[:app]} -it -p 80:9008 -d #{image} >/dev/null 2>/dev/null`.chomp

          `ansible-playbook --private-key my_demo_key -l "#{match[:env]}" -u ubuntu \
            -e org="#{org}" \
            -e _port=80:9008 \
            -e app_name="#{match[:app]}" \
            -e tag="#{commit}" \
            deploy.yml`

          client.say(text: "deployed #{match[:app]}/#{match[:branch]} (#{short_commit}) to #{match[:env]} successfully!", channel: data.channel)
        else
          client.say(text: "docker image (#{short_commit}) is not found!", channel: data.channel)
          client.say(text: "deployment is failed!", channel: data.channel)
        end
      else
        client.say(text: "deployment is failed!", channel: data.channel)
      end
    else
      client.say(text: "branch (#{match[:branch]}) is not found!", channel: data.channel)
    end
  end
end

DeletifyBot.run
