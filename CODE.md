# Code Reading for climate_control gem

## Code Stats

cloc|github.com/AlDanial/cloc v 1.72  T=0.07 s (151.5 files/s, 6364.9 lines/s)
--- | ---

Language|files|blank|comment|code
:-------|-------:|-------:|-------:|-------:
Ruby|8|62|8|237
Markdown|1|29|0|73
YAML|1|0|0|11
--------|--------|--------|--------|--------
SUM:|10|91|8|321

## Gemspec

```ruby
# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "climate_control/version"

Gem::Specification.new do |gem|
  gem.name          = "climate_control"
  gem.version       = ClimateControl::VERSION
  gem.authors       = ["Joshua Clayton"]
  gem.email         = ["joshua.clayton@gmail.com"]
  gem.description   = %q{Modify your ENV}
  gem.summary       = %q{Modify your ENV easily with ClimateControl}
  gem.homepage      = "https://github.com/thoughtbot/climate_control"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rspec", "~> 3.1.0"
  gem.add_development_dependency "rake", "~> 10.3.2"
  gem.add_development_dependency "simplecov", "~> 0.9.1"
end
```

## Code


### lib/climate_control.rb

```ruby
require "climate_control/environment"
require "climate_control/errors"
require "climate_control/modifier"
require "climate_control/version"

module ClimateControl
  @@env = ClimateControl::Environment.new

  def self.modify(environment_overrides, &block)
    Modifier.new(env, environment_overrides, &block).process
  end

  def self.env
    @@env
  end
end
```

### lib/climate_control/environment.rb

```ruby
require "thread"
require "forwardable"

module ClimateControl
  class Environment
    extend Forwardable

    def initialize
      @semaphore = Mutex.new
    end

    def_delegators :env, :[]=, :to_hash, :[], :delete
    def_delegator :@semaphore, :synchronize

    private

    def env
      ENV
    end
  end
end
```

### lib/climate_control/errors.rb

```ruby
module ClimateControl
  class UnassignableValueError < ArgumentError; end
end
```

### lib/climate_control/modifier.rb

```ruby
module ClimateControl
  class Modifier
    def initialize(env, environment_overrides = {}, &block)
      @environment_overrides = stringify_keys(environment_overrides)
      @block = block
      @env = env
    end

    def process
      @env.synchronize do
        begin
          prepare_environment_for_block
          run_block
        ensure
          cache_environment_after_block
          delete_keys_that_do_not_belong
          revert_changed_keys
        end
      end
    end

    private

    def prepare_environment_for_block
      @original_env = clone_environment
      copy_overrides_to_environment
      @env_with_overrides_before_block = clone_environment
    end

    def run_block
      @block.call
    end

    def copy_overrides_to_environment
      @environment_overrides.each do |key, value|
        begin
          @env[key] = value
        rescue TypeError => e
          raise UnassignableValueError,
            "attempted to assign #{value} to #{key} but failed (#{e.message})"
        end
      end
    end

    def keys_to_remove
      @environment_overrides.keys
    end

    def keys_changed_by_block
      @keys_changed_by_block ||= OverlappingKeysWithChangedValues.new(@env_with_overrides_before_block, @env_after_block).keys
    end

    def cache_environment_after_block
      @env_after_block = clone_environment
    end

    def delete_keys_that_do_not_belong
      (keys_to_remove - keys_changed_by_block).each {|key| @env.delete(key) }
    end

    def revert_changed_keys
      (@original_env.keys - keys_changed_by_block).each do |key|
        @env[key] = @original_env[key]
      end
    end

    def clone_environment
      @env.to_hash
    end

    def stringify_keys(env)
      env.each_with_object({}) do |(key, value), hash|
        hash[key.to_s] = value
      end
    end

    class OverlappingKeysWithChangedValues
      def initialize(hash_1, hash_2)
        @hash_1 = hash_1 || {}
        @hash_2 = hash_2
      end

      def keys
        overlapping_keys.select do |overlapping_key|
          @hash_1[overlapping_key] != @hash_2[overlapping_key]
        end
      end

      private

      def overlapping_keys
        @hash_2.keys & @hash_1.keys
      end
    end
  end
end
```

### lib/climate_control/version.rb

```ruby
module ClimateControl
  VERSION = "0.1.0"
end
```


## Specs

### ... read specs

