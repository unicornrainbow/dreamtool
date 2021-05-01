namespace :editions do
  desc ""
  task compile: :environment do
    Rails.logger.info "Edition Compile Beginning"
    edition = Edition.last
    EditionCompiler.new(edition).compile!
    Rails.logger.info "Edition Compile Complete"
  end
end
