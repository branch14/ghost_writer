require 'open-uri'
# https://github.com/svenfuchs/i18n/tree/master/lib/i18n/backend

# I18n.backend

module GhostReader
  class I18nBackend
    
    def load_translations(*args)
      raise NotImplementedError
    end

    def store_translations(locale, data, options = {})
      raise NotImplementedError
    end

    def translate(locale, key, options = {})
      open("http://localhost:3000/api/1/#{locale}/#{key}").read
    end

    def localize(locale, object, format = :default, options = {})
      raise NotImplementedError
    end

    def available_locales
      raise NotImplementedError
    end

    def reload!
    end

  end
end

#I18n.backend = GhostReader::I18nBackend.new

#I18n::Backend::Chain.new(I18n::Backend::ActiveRecord.new, I18n.backend)


