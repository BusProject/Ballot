task :deploy do
  sh "bundle exec rake spec"
  sh "git checkout -B compiled"
  sh "git merge -s recursive -Xtheirs master"
  sh 'bundle exec rake assets:clean'
  sh 'bundle exec rake i18n:js:export'
  sh 'bundle exec rake assets:precompile'
  sh 'git add public/assets/'
  sh "git commit -am 'Precompiling assets'"
  sh "git push -f heroku compiled:master"
  sh "git checkout master"
  sh 'rm app/assets/javascripts/i18n/translations.js'
  sh '/usr/bin/open -a "/Applications/Google Chrome.app" "http://theballot.org/"'
  sh '/usr/bin/open -a "/Applications/Google Chrome.app" "http://theballot.org/admin"'
end