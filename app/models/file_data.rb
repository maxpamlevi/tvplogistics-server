# frozen_string_literal: true

# == Schema Information
#
# Table name: file_data
#
#  id                :bigint           not null, primary key
#  file              :string
#  file_so_bk        :string
#  file_so_cont      :string
#  file_so_disc      :string
#  file_so_load      :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  file_barge_id     :string
#  file_discharge_id :string
#  file_external_id  :string
#  file_internal_id  :string
#  file_load_id      :string
#  file_truck_id     :string
#  service_order_id  :integer          not null

require 'open3'
class FileData < ApplicationRecord
  belongs_to :service_order
  mount_uploader :file, FileUploader
  DATA = %w[load_dis trans wh].freeze

  def url
    base = ENV['R2_URL']

    return "#{base}#{file.path}" if file.present? && base.present?

    nil
  end

  def self.migrate_drive_to_r2
    ids = FileData.where(file: nil).pluck(:service_order_id)
    ServiceOrder.where(id: ids).each_slice(5) do |service_orders|
      service_orders.each do |s|
        file_data = s.file_data
        next if file_data.blank? || file_data.file.present?

        urls = []
        if s.so_type == 'SO DISC'
          urls << { url: "https://docs.google.com/feeds/download/spreadsheets/Export?key=#{file_data.file_so_disc}&exportFormat=xlsx", name: 'BARGE' }
        end
        if s.so_type == 'SO LOAD'
          urls << { url: "https://docs.google.com/feeds/download/spreadsheets/Export?key=#{file_data.file_so_load}&exportFormat=xlsx", name: 'BARGE' }
        end
        if s.so_type == 'SO CONT'
          urls << { url: "https://docs.google.com/feeds/download/spreadsheets/Export?key=#{file_data.file_so_cont}&exportFormat=xlsx", name: 'BARGE' }
        end

        if s.so_type == 'SO BINH KHUONG'
          urls << { url: "https://docs.google.com/feeds/download/spreadsheets/Export?key=#{file_data.file_so_bk}&exportFormat=xlsx", name: 'BARGE' }
        end

        if s.so_type == 'SO'
          urls = [
            { url: "https://docs.google.com/feeds/download/spreadsheets/Export?key=#{file_data.file_barge_id}&exportFormat=xlsx", name: 'BARGE' },
            { url: "https://docs.google.com/feeds/download/spreadsheets/Export?key=#{file_data.file_discharge_id}&exportFormat=xlsx",name: 'WL DISCHARGE' },
            { url: "https://docs.google.com/feeds/download/spreadsheets/Export?key=#{file_data.file_external_id}&exportFormat=xlsx",name: 'EXTERNAL' },
            { url: "https://docs.google.com/feeds/download/spreadsheets/Export?key=#{file_data.file_internal_id}&exportFormat=xlsx",name: 'INTERNAL' },
            { url: "https://docs.google.com/feeds/download/spreadsheets/Export?key=#{file_data.file_load_id}&exportFormat=xlsx",name: 'WL LOAD' },
            { url: "https://docs.google.com/feeds/download/spreadsheets/Export?key=#{file_data.file_truck_id}&exportFormat=xlsx",name: 'TRUCK' },
          ]
        end

        merge_excel_files(file_data, s.so, urls)
      end
    end
  end

  def self.merge_excel_files(data, so, urls)
    return if urls.blank? || data.blank? || so.blank?

    script_path = Rails.root.join('index.js')
    command = "node #{script_path} '#{urls.to_json}' #{so}"
    stdout, stderr, status = Open3.capture3(command)

    begin
      if status.success?
        puts "upload #{so}.xlsx"
        file = File.open("tmp/#{so}.xlsx")
        data.file = file
        data.save!
        File.delete(file.path)
        Rails.logger.info("Command executed successfully: #{stdout}")
      else
        Rails.logger.error("Command failed with status (#{status.exitstatus}): #{stderr}")
      end
    rescue StandardError => e
      puts 'Error ---'
      puts e
    end
  end

end
