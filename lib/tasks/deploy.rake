task :deploy do
  sh 'git checkout compiled'
  sh 'git merge master compiled'
  sh 'bundle exec rake assets:clean'
  sh 'bundle exec rake assets:precompile'
  sh 'git add public/assets/'
  sh "git commit -am 'Precompiling assets'"
  sh "git push heroku master"
  sh 'git checkout master'
  sh 'curl -f "http://the-ballot.herokuapp.com"'
  sh 'curl -f "http://the-ballot.herokuapp.com?q=true"'
  sh '/usr/bin/open -a "/Applications/Google Chrome.app" "http://the-ballot.herokuapp.com"'
  sh '/usr/bin/open -a "/Applications/Google Chrome.app" "http://the-ballot.herokuapp.com/admin"'
end