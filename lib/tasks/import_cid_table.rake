require 'bulk_insert'

module ImportTasks
  class Cid
    DATA_FILES_PATH = './data'
    FILENAME = 'cid_data.csv'

    SEPARATORS = {
      row: "\n",
      column: ','
    }.freeze
  end
end

namespace :db do
  namespace :import do
    desc 'Import CID table to the database'
    task cid: :environment do
      logger = Logger.new(STDOUT)
      csv_path = "#{ImportTasks::Cid::DATA_FILES_PATH}/#{ImportTasks::Cid::FILENAME}"

      logger.info('-> Reading CSV file...')

      Cid.bulk_insert(ignore: true) do |worker|
        CSV.foreach(csv_path) do |row|
          worker.add code: row[0], description: row[1]
        end
      end

      logger.info('--- Finished!')
    end
  end
end
