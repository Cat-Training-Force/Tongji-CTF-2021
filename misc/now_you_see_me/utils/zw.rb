# Kowalski Dark <darkkowalski2012@gmail.com>

# Unicode Zero Width Space and Zero Width Joiner
class ZW
  def self.zero
    "\u200b"
  end

  def self.one
    "\u200d"
  end

  def self.encode(flag: '')
    # Notice: flag should only contains ASCII characters
    encoded = ""
    flag.encode('ascii').each_byte do |byte|
      # we assume 1 byte == 8 bits
      8.times do |n|
        bit = (byte >>(7 - n)) & 0b1
        bit == 0 ? encoded << self.zero : encoded << self.one
      end
    end
    encoded
  end

  def self.decode(encoded: '')
    binary = []
    encoded.each_char do |ch|
      ch == self.zero ? binary << 0 : binary << 1
    end
    # to ascii here
    binary.each_slice(8).map { |slice| slice.join.to_i(2) }.pack('c*')
  end
end

class CLI
  def self.encode
    stdin_flag = gets.chomp
    return if stdin_flag.nil? || stdin_flag.empty?

    File.open('encoded_flag.txt', 'w') do |f|
      f.write ZW.encode(flag: stdin_flag)
    end
  end

  def self.decode
    stdin_encoded_flag = gets.chomp
    return if stdin_encoded_flag.nil? || stdin_encoded_flag.empty?

    puts ZW.decode(encoded: stdin_encoded_flag)
  end
end
