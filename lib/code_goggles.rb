require 'code_goggles/version'
require 'erb'

module CodeGoggles
  def self.generate(gem_name)
    puts Renderer.new(gem_name).render
  end

  class Renderer
    attr_accessor :cloc_output, :files, :gem_name, :gemspec_content

    def initialize(gem_name)
      gem_location = `bundle show #{gem_name}`.chomp
      @cloc_output = `cloc --md #{gem_location}`.strip
      filenames = [
        "lib/climate_control.rb",
        "lib/climate_control/environment.rb",
        "lib/climate_control/errors.rb",
        "lib/climate_control/modifier.rb",
        "lib/climate_control/version.rb",
      ]
      @files = filenames.each_with_object({}) do |file, result|
        result[file] = File.read("#{gem_location}/#{file}").chomp
      end
      @gem_name = gem_name
      @gemspec_content = File.read("#{gem_location}/#{gem_name}.gemspec").chomp
    end

    def render
      ERB.new(File.read("./templates/CODE.md")).result(binding)
    end
  end
end
