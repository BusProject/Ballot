task :deploy do
  #sh 'bundle exec rake assets:precompile'
  sh "git commit -am 'Precompiling assets'"
  sh "git push heroku master"
end