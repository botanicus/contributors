#!/usr/bin/env nake
# encoding: utf-8

load File.expand_path("../lib/contributors.nake", __FILE__)

Task[:contributors].config[:format] = Proc.new { |email, data| "#{data[:name]}: #{data[:LOC]}" }
