require 'i18n'

module CreativeCommonsRails
  class LicenseInfo
    attr_accessor :type, :jurisdiction, :version

    # ensure the license exists in the license index
    def self.find(attributes = {})
      index = license_index
      [:jurisdiction, :version, :type].each do |key|
        raise "You must specify the #{attr} to find a licence" if attributes[key].nil?
        index = index[attributes[key].to_s]
        raise "Unknown license #{key}: #{attributes[key]}" if index.nil? || !index
      end

      LicenseInfo.new(attributes[:type],attributes[:jurisdiction],attributes[:version])
    end

    def self.available_jurisdictions
      license_index.keys
    end

    def self.available_types(jurisdiction)
      license_index[jurisdiction.to_s].keys
    end

    def self.available_versions(jurisdiction, type)
      license_index[jurisdiction].select{|k,v| v[type]}.keys
    end

    def initialize(type, jurisdiction, version)
      @type, @jurisdiction, @version = type, jurisdiction, version
    end

    def formatted_type
      type.to_s.gsub('_', '-')
    end

    def deed_url
      if jurisdiction == :unported
        "http://creativecommons.org/licenses/#{formatted_type}/#{version}/deed.#{language}"
      else
        "http://creativecommons.org/licenses/#{formatted_type}/#{version}/#{jurisdiction}/deed.#{language}"
      end
    end

    def icon_url(size = :normal)
      "http://i.creativecommons.org/l/#{formatted_type}/#{version}/#{size == :compact ? '80x15' : '88x31'}.png"
    end

    def translated_title
      I18n.t :license_title, license_type: translated_type
    end

    def translated_type
      I18n.t "license_type_#{type}", version: version, jurisdiction: I18n.t(jurisdiction)
    end

    def language
      I18n.locale
    end

    private
    def self.license_index
      gem_root = Gem::Specification.find_by_name("creative_commons_rails").gem_dir
      @index ||= YAML.load_file("#{gem_root}/config/license_list.yaml")
    end
  end
end