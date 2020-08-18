class Secrets
  class << self
    def get(secret)
      if File.file?('../app/assets/data/secrets.yml')
        File.open('../app/assets/data/secrets.yml') { |file| YAML.safe_load(file) }[secret]
      else
        ENV[secret]
      end
    end
  end
end
