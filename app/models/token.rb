require 'base64'
require 'digest'

class Token < ActiveRecord::Base

  attr_accessible :raw, :project, :project_id, :key
  
  belongs_to :project
  has_many :translations, :dependent => :destroy

  has_ancestry :cache_depth => true
  
  validates :project, :presence => true

  # FIXME this doesn't work
  # before_save :update_full_key, :if => proc { |t| t.ancestry_changed? || t.new_record? }

  # accepts_nested_attributes_for :translations
  # 
  # def translations_attributes
  #   attrs = Translation.accessible_attributes
  #   translations.inject({}) do |result, translation|
  #     result.merge translation.id =>
  #       Hash[ translation.attributes.select do |k, v|
  #               attrs.include?(k) or k == 'id'
  #             end ]
  #   end
  # end

  # performs a three way merge of...
  #  * existing translations
  #  * missing translations
  #  * attributes provided
  def update_or_create_all_translations(attributes={})
    missing_locales.each { |locale| translations.build :locale => locale }
    attributes.each do |code, attr|
      merger = translations_by_code[code].attributes.merge attr
      translations_by_code[code].attributes = merger
    end
    translations_by_code.values.tap { |translations| translations.each(&:save!) } 
  end

  # returns a hash 
  def translations_by_code
    translations.inject({}) { |result, t| result.merge t.code => t }
  end

  def hits_counter
    translations.sum(:hits_counter)
  end

  def miss_counter
    translations.sum(:miss_counter)
  end

  # TODO
  def has_interpolations?
    false
  end

  # returns an array of missing locales or an empty array otherwise
  def missing_locales
    project.locales.reject do |locale|
      translations.map(&:locale_id).include? locale.id
    end
  end

  # this is of temporary need to migrate over to ancestry
  # and will go after data migrations
  def set_ancestry!
    return if raw.nil?
    node = nil
    keys = raw.split '.'
    logger.debug "The keys are #{keys.inspect}."
    output = []
    keys.each_with_index do |key, index|
      logger.debug "Key #{index + 1} of #{keys.size}: '#{key}'."
      if index == keys.size - 1 # last
        logger.debug "This is the last key."
        if node.nil?
          logger.debug "Node is and will remain a root node."
        else
          self.key = key
          self.parent = node
          save!
          logger.debug "Made self ('#{key}') to a child node of '#{node.key}'."
          node = self
        end
      else
        if node.nil?
          node = project.tokens.at_depth(0).where(:key => key).first
          logger.debug "Creating root node for '#{key}'." if node.nil?
          node ||= project.tokens.create!(:key => key)
        else
          next_node = node.children.where(:key => key).first
          logger.debug "Creating node for '#{key}' under '#{node.key}'." if next_node.nil?
          next_node ||= node.children.create!(:key => key, :project => project)
          node = next_node
        end
      end
      output << node
      logger.debug "Next node is #{node.inspect}."
    end
    output
  end

  def translation_for(locale)
    translations.where(:locale_id => locale.id).first
  end

  def update_full_key
    self.full_key = (ancestors.map(&:key) << key) * '.'
  end

  private

end

