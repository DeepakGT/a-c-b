# frozen_string_literal: true

# Reemplazamos el constants helper (deprecated) con un yml
require 'ostruct'
require 'yaml'

all_config = YAML.load_file("#{Rails.root}/config/constants.yml") || {}
Constant = OpenStruct.new(all_config)
