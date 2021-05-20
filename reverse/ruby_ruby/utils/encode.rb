#!/usr/bin/env ruby

class Compiler
  def self.jamming
    source = <<~GETTYSBURG
      Four score and seven years ago our fathers brought forth on this continent,
      a new nation, conceived in Liberty, and dedicated to the proposition that
      all men are created equal.
    GETTYSBURG

    source.unpack('B*')
  end

  def self.template(flag: '', dummy: '')
    flag = flag.unpack('B*')
    dummy = dummy.unpack('B*')
    jamming = self.jamming
    result = <<~TEMPLATE
      class Flag
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

        def self.to_a
          $stderr.puts #{jamming}
          [self.dummy.pack('B*')]
        end

        def self.hint
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
