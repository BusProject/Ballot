task :seed do
  sh 'ruby script/add_candidates.rb "lib/candidates.csv"'
  sh 'ruby script/add_measures.rb "lib/measures.csv"'
end