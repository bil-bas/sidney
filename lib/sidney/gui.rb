# encoding: utf-8

begin
  require_relative '../../../fidgit/lib/fidgit'
rescue Exception => ex
  require 'fidgit'
end

include Fidgit

Fidgit.font_name = File.expand_path(File.join(__FILE__, '..', '..', '..', 'media', 'fonts', 'SFPixelate.ttf'))

