require 'fileutils'
#
# Prints/Compiles and edition
class EditionsPrintWorker
  include Sidekiq::Worker

  def perform(print_id)
    logger.info "Print #{print_id} Beginning"
    print = Print.find(print_id)
    edition = print.edition
    compiler = EditionCompiler.new(edition)
    compiler.compile!

    # Move the print output to share path
    FileUtils.mkdir_p print.share_path
    FileUtils.rmdir print.share_path
    FileUtils.mv compiler.output_dir, print.share_path

    print.capture_screen_print!
    print.add_webpub_manifest!
    print.zip!

    # Trigger print complete event on the edition.
    print.print_complete

    logger.info "Print #{print_id} Complete"
  end
end
