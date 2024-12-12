namespace :db do
  # desc "Backup database to backups folder"
  task :backup => :environment do
    require_relative '../../app/uploaders/backup_uploader'

    db_config = ActiveRecord::Base.connection_db_config
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    backup_dir = Rails.root.join('db', 'backups')
    FileUtils.mkdir_p(backup_dir)
    backup_file = backup_dir.join("backup_#{timestamp}.sql")

    uri = URI.parse(db_config.url)
    db_name = uri.path[1..-1]
    host = uri.host
    username = uri.user
    password = uri.password
    port = uri.port || 5432

    puts "Backup database: #{db_name}"
    puts password

    command = [
      'pg_dump',
      "--host=#{host}",
      "--port=#{port}",
      "--username=#{username}",
      "--dbname=#{db_name}",
      '--format=custom',
      "--file=#{backup_file}"
    ].join(' ')



    if system(command)
      uploader = BackupUploader.new
      uploader.store!(File.open(backup_file))

      puts "Database backup successfully created: #{backup_file}"
    else
      puts 'Error creating database backup'
    end
    #
    # # Xóa biến môi trường PGPASSWORD
    # ENV['PGPASSWORD'] = nil

    # Tự động xóa các backup cũ hơn 7 ngày
    # old_backups = Dir[backup_dir.join("backup_*.sql")].select do |file|
    #   File.mtime(file) < 7.days.ago
    # end

    # old_backups.each do |file|
    #   File.delete(file)
    #   puts "Deleted old backup: #{file}"
    # end
  end


  task :restore => :environment do
    backup_dir = Rails.root.join('db', 'backups')
    latest_backup = Dir[backup_dir.join('backup_*.sql')].max_by { |f| File.mtime(f) }

    if File.exist?(latest_backup)
      puts latest_backup
    else
      puts "Backup file not found: #{latest_backup}"
      exit 1
    end

    db_config = ActiveRecord::Base.connection_db_config
    uri = URI.parse(db_config.url)
    db_name = uri.path[1..-1]
    host = uri.host
    username = uri.user
    password = uri.password
    port = uri.port || 5432

    puts "Backup database: #{db_name}"
    puts password

    command = [
      'pg_restore',
      "--host=#{host}",
      "--port=#{port}",
      "--username=#{username}",
      "--dbname=#{db_name}",
      '--clean',
      '--no-owner',
      '--no-acl',
      latest_backup.to_s
    ].join(' ')

    if system(command)
      puts "Database successfully restored from: #{latest_backup}"
    else
      puts "Error restoring database from: #{latest_backup}"
    end
  end
end