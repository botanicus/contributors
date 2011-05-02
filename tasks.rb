#!/usr/bin/env nake
# encoding: utf-8

$LOAD_PATH.unshift(File.expand_path("../lib", __FILE__))

load "contributors.nake"

Task[:contributors].config[:format] = Proc.new { |author, data| "#{author.inspect}: #{data.inspect}" }
