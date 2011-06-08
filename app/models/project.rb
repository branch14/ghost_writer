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
    log "handle missing in #{filename}\n"
    data = File.open(filename, 'r').read
    missed = JSON.parse(data)  
    missed.each do |key, val|
      token = self.tokens.where(:raw => key).first
      if token.nil?
        token = self.tokens.create(:raw => key)
        token.translations.each do |translation|
          log "  adjusting translation for '#{translation.locale.code}' #{key}"
          attrs = { :hits => val['count'][translation.locale.code] }
          content = val['default'][translation.locale.code] unless val['default'].nil?
          content = val[:default][translation.locale.code] unless val[:default].nil?
          content ||= key
          attrs[:content] = content unless content.nil?
          log "    content: #{attrs[:content]}"
          log "    hits:    #{attrs[:hits]}"
          log "    attrs:   #{attrs.inspect}"
          translation.reload
          #translation.update_attributes attrs
          #log("VE:"+translation.errors.full_messages) unless translation.valid?
          #translation.attributes.merge! attrs
          translation.content = content
          translation.hits = val['count'][translation.locale.code]
          #log translation.attributes.inspect 
          log "    translation valid: #{translation.valid?}"
          log "      token valid: #{translation.token.valid?}"
          log "      locale valid: #{translation.locale.valid?}"
          #log(translation.errors.full_messages)
          translation.save!
          unless translation.content == content
            log "    FAILED. uhoh. #{translations.inspect}\n"
            raise "hey, you have earned a content!=content error batch: #{translation.inspect}"
              #translation.errors.full_messages.inspect
          end
          log "    SAVED WITH SUCCESS\n"
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
