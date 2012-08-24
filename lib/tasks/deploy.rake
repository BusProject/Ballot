task :deploy do
  sh 'bundle exec rake assets:precompile'
  sh 'git add public/assets/'
  sh "git commit -am 'Precompiling assets'"
  sh "git push heroku master"
  sh 'curl -f "http://the-ballot.herokuapp.com"'
  sh '/usr/bin/open -a "/Applications/Google Chrome.app" "http://google.com"'
end