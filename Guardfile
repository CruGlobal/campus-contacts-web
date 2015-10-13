# A sample Guardfile
# More info at https://github.com/guard/guard#readme

group :red_green_refactor, halt_on_fail: true do
  guard 'minitest', keep_failed: false, all_on_start: false, all_after_pass: false do
    watch(%r{app/models/(.+)\.rb})                     { |m| "test/models/#{m[1]}_test.rb" }
    watch(%r{app/controllers/(.+)\.rb})                { |m| "test/controllers/#{m[1]}_test.rb" }
    watch(%r{app/controllers/apis/v3/(.+)\.rb})        { |m| "test/controllers/apis/v3/#{m[1]}_test.rb" }
    watch(%r{app/views/.+\.rb})                        { 'test/integration' }
    watch(%r{lib/(.+)\.rb})                            { |m| "test/#{m[1]}_test.rb" }
    watch(%r{test/.+_test.rb})
    watch('app/controllers/application_controller.rb') { ['test/functional', 'test/integration'] }
    watch('test/test_helper.rb')                       { 'test' }
  end

  guard :rubocop, all_on_start: false, cli: ['--format', 'clang', '--rails', '--auto-correct'] do
    watch(%r{.+\.rb$})
    watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
  end
end