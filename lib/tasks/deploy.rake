task :deploy do
  sh "git checkout -B compiled"
  sh "git merge -s recursive -Xtheirs master"
  sh 'bundle exec rake assets:clean'
  sh 'bundle exec rake assets:precompile'
  sh 'git add public/assets/'
  sh "git commit -am 'Precompiling assets'"
  sh "git push heroku compiled:master"
  sh 'curl -f "http://theballot.org/"'
  sh 'curl -f "http://theballot.org/?q=true"'
  sh "git checkout master"
  sh '/usr/bin/open -a "/Applications/Google Chrome.app" "http://theballot.org/"'
  sh '/usr/bin/open -a "/Applications/Google Chrome.app" "http://theballot.org/admin"'
end