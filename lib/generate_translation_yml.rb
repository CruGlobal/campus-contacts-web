#!/usr/bin/env ruby
# rubocop:disable Rails/Output
# roots = `egrep '^  [a-z]' config/locales/en.yml`
# roots = roots.split("\n").map(&:strip)
# p roots
#
# keys = `egrep "'(([a-z0-9_]+\.)+([a-z0-9_]+))'" app/assets/javascripts/angular/components/organizationOverview/organizationOverview.html`
# keys.split("\n")
# p keys

require 'yaml'

def concat_key(base, children)
  children.map do |key, value|
    new_base = [base, key.to_s].compact.join('.')
    if value.is_a? Hash
      concat_key(new_base, value)
    else
      new_base
    end
  end
end

translations = YAML.load_file('config/locales/en.yml')['en']

translation_keys = concat_key(nil, translations).flatten

# sort keys so the most specific keys are at the top
translation_keys = translation_keys.sort_by { |k| k.count('.') }.reverse

# puts translation_keys
# exit
# ruby lib/translations.rb > patterns.txt
# fgrep -f patterns.txt -r -o -h app/assets/javascripts/angular | sort | uniq -c | sort -n
# 5 monthly
# 6 sporadically
# 9 general.cancel
# 15 weekly
# 40 leader
# 108 member
# 194 label
# 438 group

pattern = translation_keys.map { |k| "-e #{k} " }.join

puts 'Finding used keys'
used_keys = `fgrep #{pattern} -r -o -h app/assets/javascripts/angular | sort -u`.split("\n")

puts 'Extracting english strings for new file'
used_hash = {}
used_keys.each do |key|
  key_parts = key.split('.')
  english = translations.dig(*key_parts)
  *parents, last = key.split('.')
  hash = used_hash
  parents.each do |part|
    hash[part] ||= {}
    hash = hash[part]
  end
  hash[last] = english
end

used_hash = { 'en' => used_hash }
File.open('used_en.yml', 'w') { |f| f.write used_hash.to_yaml }
puts 'File saved successfully.'
