namespace :jobs do
  # Refetch incomplete slyps
  task :refetch_slyps => :environment do
    Slyp.all.each do |slyp|
      Slyp.fetch(slyp.url)
    end
  end
end