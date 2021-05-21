#!/usr/bin/env ruby
require 'zlib'
require 'base64'
class Compiler
  def self.jamming
    source = <<~GETTYSBURG
      Four score and seven years ago our fathers brought forth on this continent,
      a new nation, conceived in Liberty, and dedicated to the proposition that
      all men are created equal.
    GETTYSBURG

    source.unpack('B*').join
  end

  def self.template(flag: '', dummy: '')
    flag = Base64.encode64(Zlib::deflate(flag)).unpack('B*')
    dummy = dummy.unpack('B*')
    jamming = self.jamming
    result = <<~TEMPLATE
      class Flag
        require 'zlib'
        require 'base64'
        def self.flag
          $stderr.puts #{jamming}
          #{dummy}
        end

        def self.to_s
          $stderr.puts #{jamming}
          self.flag.pack('B*')
        end

        def self.dummy
          $stderr.puts #{jamming}
          #{flag}
        end

        def self.get_lower_half
          $stderr.puts #{jamming}
        end

        def self.to_a
          $stderr.puts #{jamming}
          [Zlib::Inflate.inflate(Base64.decode64(self.dummy.pack('B*')))]
        end

        def self.get_upper_half
          $stderr.puts #{jamming}
        end

        def self.get_nothing
          'RubyVM::InstructionSequence'
        end
      end
    TEMPLATE
  end

  def self.compile(flag: '', dummy: '')
    bytecode = RubyVM::InstructionSequence.compile(self.template(flag: flag, dummy: dummy))

    File.write( 'flag.rb', bytecode.to_binary)
  end
end

# Encode!
Compiler.compile(flag: "tjctf{R0smOnt1s}", dummy: "tjctf{YukihiroMatsumoto}") #=> flag.rb
