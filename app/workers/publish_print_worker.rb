require 'fileutils'
require 'curb'
#
# Prints/Compiles and edition
class PublishPrintWorker
  include Sidekiq::Worker

  def perform(print_id)
    logger.info "Publish Print #{print_id} Beginning"
    print = Print.find(print_id)
    edition = print.edition

    c = Curl::Easy.new(print.store_link)
    c.multipart_form_post = true

    print_size = print.file_size.to_f.to_s
    print_size_units = print.file_size.gsub(/[^a-zA-Z]/, '')

    # Need to upload zip and relevant attributes
    # TODO: This should be reading attributes from the print.
    c.http_post(Curl::PostField.content('edition[name]',  edition.name),
                Curl::PostField.content('edition[publish_date]', edition.publish_date.to_s),
                Curl::PostField.content('edition[price]',    edition.price.to_s),
                Curl::PostField.content('edition[volume_label]', edition.volume_label),
                Curl::PostField.content('edition[size]', print_size),
                Curl::PostField.content('edition[size_units]', print_size_units),
                Curl::PostField.file('zip', print.zip_path))


    logger.info "Publish Print #{print_id} Complete"
  end
end
