require 'digest/sha1'

class Print
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  has_mongoid_attached_file :signature        # The signature to match the compiled version.

  # The version number should be incremended with each sequential print. I
  # should be set based on a query when the print is created.
  field :version, type: Integer, default: 1

  field :file_size, type: String # Size of the zipped output.

  # TODO: These should be copied at print time. (The object graph should be
  # serialized into a tree and stored for future reinstantiation)
  delegate :publish_date, :fmt_price,
    :store_link, :volume_label, :publication, to: :edition

  before_create :set_version
  before_save :check_for_signature

  belongs_to :edition

  def set_version
    previous_print = edition.prints.order_by(:version.desc).first
    if previous_print
      self.version = previous_print.version + 1
    end
  end

  state_machine :state, initial: :initial do
    before_transition :initial => :printing, do: :queue_print
    after_transition  :printing => :printed, do: :broadcast_print_complete
    before_transition :printed => :published, do: :publish_print_to_store

    event :print_start do
      transition :initial => :printing
    end

    event :print_complete do
      transition :printing => :printed
    end

    #event :sign do
      #transition :printed => :signed
    #end

    event :publish do
      transition :printed => :published
    end

    event :reset do
      transition any => :initial
    end
  end


  def name
    stripped_name = edition.name.underscore.gsub(/[^a-zA-Z\d\s]/, '').gsub(' ', '_')
    "#{stripped_name}_v#{version}"
  end

  # Checks for being added, if found, marks as signed.
  def check_for_signature
    if signature_file_name_changed?
      sign if signature.present?
    end
    true
  end

  def publish_print_to_store
    PublishPrintWorker.perform_async(to_param)
  end

  def queue_print
    EditionsPrintWorker.perform_async(id.to_s)
  end

  def broadcast_print_complete
    message = {:channel => "/editions/#{edition.to_param}", :data => "print_complete", :ext => {:auth_token => FAYE_TOKEN}}
    uri = URI.parse(FAYE_URL)
    Net::HTTP.post_form(uri, :message => message.to_json)
  end

  def print_complete?
    !["initial", "printing"].include?(state)
  end

  def edition_share_path
    "#{Rails.root}/share/compiled_editions/#{edition.id.to_s}"
  end

  # Share path on disk where the print is stored
  def share_path
    "#{edition_share_path}/#{id.to_s}"
  end

  def zip_path
    "#{share_path}/#{name}.zip"
  end

  def capture_screen_print!
    # Captures screenshot using webkit2png in path, rename cover-clipped.png to
    # cover.png for better convention.
    system "cd #{share_path}; webkit2png -z 2.0 -C -s 1 --filename=cover --clipwidth=2880 --clipheight=1800 #{share_path}/main.html; mv cover-clipped.png cover.png" # Assumes mail.html
  end

  # Creates the webpub manifest on disk if one doesn't exist.
  def add_webpub_manifest!
    system "cd #{share_path}; #{Rails.root.join('script/create_manifest')} #{edition.store_link}"
  end

  # Zips the output
  def zip!
    system "cd #{share_path}; zip -r #{name}.zip ."

    # Measure and record file size
    file_size = ApplicationController.helpers.number_to_human_size(File.size(File.join(share_path, "#{name}.zip")))
    update_attribute(:file_size, file_size)
  end


end
