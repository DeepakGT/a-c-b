# frozen_string_literal: true

# Reemplazamos el constants helper (deprecated) con un yml
require 'ostruct'
require 'yaml'

all_config = YAML.load_file("#{Rails.root}/config/constants.yml") || {}
env_config = all_config[Rails.env] || {}
Constant = OpenStruct.new(env_config)
