require_relative 'header'
require_relative 'stanza'

module Obo
  class Parser
    STANZA_START = /^\[(.*?)\]/
    TAG_VALUE    = /^(.*?):\s*([^!]*)\s*(.*?)\n/

    def initialize(input)
      if input.respond_to? :readline
        @io = input
      else
        @io = File.open input
      end
    end

    def elements(io = @io)
      Enumerator.new do |yielder|
        header = Header.new
        while io.gets.match TAG_VALUE
          header.add($1, $2)
        end

        yielder << header

        io.gets until $_.match(STANZA_START)
        stanza = Stanza.new($1.strip)

        while io.gets
          case $_
          when TAG_VALUE
            stanza.add($1, $2.strip)
          when STANZA_START
            yielder << stanza
            stanza = Stanza.new($1.strip)
          end
        end

        yielder << stanza
        rewind
      end
    end

    def rewind(io = @io)
      io.pos = 0 if io.is_a? File
    end

  end
end

