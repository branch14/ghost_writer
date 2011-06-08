class Project < ActiveRecord::Base

  SNAPSHOT_PATH = File.join Rails.root, %w(public system snapshots)

  attr_accessor :reset
  attr_accessible :title, :permalink, :locales_attributes, :reset

  has_many :tokens
  has_many :locales
  has_many :translations, :through => :locales
  has_many :assignments
  has_many :users, :through => :assignments
  has_many :snapshots, :as => :attachable

  accepts_nested_attributes_for :locales

  validates :title, :presence => true
  validates :permalink, :presence => true,
    :format => { :with => /[:alphanum:-]+/ },
    :length => { :minimum => 4 }

  after_update :perform_reset!, :if => :reset

  def remaining_locales
    codes = locales.map &:code
    Locale.available.reject { |key, value| codes.include? key }
  end

  def aggregated_translations
    # assumption everything has been loaded eagerly
    locales.inject({}) do |result, locale|
      tokens.inject(result) do |provis, token|
        translation = token.translations.select { |t| t.locale_id == locale.id }.first
        if !translation.nil? and translation.active?
          provis.deep_merge nesting(locale.code, token.raw, translation.content)
        else
          provis
        end
      end
    end
  end

  def new_snapshot_name
    time = I18n.l Time.now, :format => :filename
    name = "translations_%s_%s.yml" % [ permalink, time ]
    File.join SNAPSHOT_PATH, name
  end
  
  def log(msg)
    if @log.nil?
      @log = File.open(File.join(Rails.root, %w(log import.log)), 'a')
      @log.sync = true
    end
    @log.puts msg
  end

  def handle_missed!(filename)
    log "PROCESSING: #{filename}"
    data = File.open(filename, 'r').read
    missed = JSON.parse(data)  
    missed.each do |key, val|
      token = self.tokens.where(:raw => key).first
      if token.nil?
        token = self.tokens.create(:raw => key)
        token.translations.each do |translation|
          attrs = { :hits => val['count'][translation.locale.code] }
          content = val['default'][translation.locale.code] unless val['default'].nil?
          content = val[:default][translation.locale.code] unless val[:default].nil?
          content ||= key
          attrs[:content] = content unless content.nil?
          #translation.reload
          translation.content = content
          translation.hits = val['count'][translation.locale.code]
          translation.save!
          unless translation.content == content
            log "ERROR: #{translation.locale.code}.#{key}"
            log val.to_yaml
          else
            log "SUCCESS: #{translation.locale.code}.#{key}"
          end
        end
      end
    end
  end
  
  private

  def nesting(locale, token, translation)
    keys = (token.split('.').reverse << locale)
    keys.inject(translation) { |result, key| { key => result } }
  end

  def perform_reset!
    snapshots.create!
    tokens.destroy_all
  end

end
