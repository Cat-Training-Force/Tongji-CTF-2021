#!/usr/bin/env ruby

encoded = File.read('flag.rb')
RubyVM::InstructionSequence.load_from_binary(encoded).eval

puts Flag      # Dummy
puts Flag.to_a # Real
