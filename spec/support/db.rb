RSpec.configure do |c|
  c.before(:suite) do |example|
    Sequel.extension :migration
    Sequel::Migrator.run(DB, 'db/migrations')
    DB[:expenses].truncate
    FileUtils.mkdir_p('log')
    require 'logger'
    DB.loggers << Logger.new('log/sequel.log')
    DB.log_info("Starting example: #{example.metadata[:description]}")
  end
  c.around(:example, :db) do |example|
    DB.transaction(rollback: :always) { example.run }
  end
  c.after(:example, :db) do |example|
    DB.log_info("Ending example: #{example.metadata[:description]}")
  end
end
