task :deploy do
  branch_to_push = `git rev-parse --abbrev-ref HEAD`
  comiled_branch = "compiled_#{Time.now.to_i}"
  begin
    blue ">>>> Checking out compiled"
    system 'git stash'
    sh "git checkout -B #{comiled_branch}"

    blue '>>>> Precompiling Assets'
    sh 'bundle exec rake assets:clean'
    sh 'bundle exec rake i18n:js:export'
    sh 'bundle exec rake assets:precompile'
    sh 'git add public/assets/'

    blue '>>>> Commiting to compiled'
    sh "git commit -am 'Precompiling assets'"

    blue '>>>> Pushing to Heroku'
    sh "git push -f heroku #{comiled_branch}:master"
  rescue Exception => e
    red "!!!! Something went wrong"
    red e.message
  ensure
    blue ">>>> Back to #{branch_to_push}"
    sh 'rm app/assets/javascripts/i18n/translations.js'
    system "git checkout #{branch_to_push}"
    sh "git branch -D #{comiled_branch}"
    system 'git stash pop'
  end
end

def blue msg
  puts "\033[34m#{msg}\033[0m"
end

def red msg
  puts "\033[35m#{msg}\033[0m"
end
