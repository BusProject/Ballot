task :deploy do
  sh "git checkout -B compiled"
  sh "git merge -s recursive -Xtheirs master"
  sh 'bundle exec rake assets:clean'
  sh 'bundle exec rake i18n:js:export'
  sh 'bundle exec rake assets:precompile'
  sh 'git add public/assets/'
  sh "git commit -am 'Precompiling assets'"
  sh "git push -f heroku compiled:master"
  sh 'rm app/assets/javascripts/i18n/translations.js'
  sh "git checkout master"
end