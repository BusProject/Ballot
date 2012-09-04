task :seed do
  sh 'bundle exec rake db:migrate'
  sh 'ruby script/add_candidates.rb "lib/candidates.csv"'
  sh 'ruby script/add_measures.rb "lib/measures.csv"'
  sh '[ -f .env ] && echo ".env already exists" || cp .env-sample .env'
end