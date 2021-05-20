#!/usr/bin/env ruby

class Compiler
  def self.template(flag: '', dummy: '')
    flag = flag.unpack('B*')
    dummy = dummy.unpack('B*')

    result = <<~TEMPLATE
      class Flag
        def self.flag
          #{dummy}
        end

        def self.to_s
          self.flag.pack('B*')
        end

        def self.dummy
          #{flag}
        end

        def self.to_a
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
Compiler.compile(flag: "flag_{real}", dummy: "flag_{dummy}") #=> flag.rb
