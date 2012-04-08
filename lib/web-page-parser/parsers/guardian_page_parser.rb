module WebPageParser
  class GuardianPageParserFactory < WebPageParser::ParserFactory
    URL_RE = Regexp.new("(www\.)?guardian\.co\.uk/[a-z-]+(/[a-z-]+)?/[0-9]{4}/[a-z]{3}/[0-9]{1,2}/[a-z-]{5,200}$")
    INVALID_URL_RE = Regexp.new("/cartoon/|/commentisfree/poll/")
    def self.can_parse?(options)
      return nil if options[:url].match(INVALID_URL_RE)
      URL_RE.match(options[:url])
    end
    
    def self.create(options = {})
      GuardianPageParserV1.new(options)
    end
  end

  # BbcNewsPageParserV1 parses BBC News web pages exactly like the
  # old News Sniffer BbcNewsPage class did.  This should only ever
  # be used for backwards compatability with News Sniffer and is
  # never supplied for use by a factory.
  class GuardianPageParserV1 < WebPageParser::BaseParser
    ICONV = nil
    TITLE_RE = Regexp.new('<meta property="og:title" content="(.*)"', Regexp::IGNORECASE)
    DATE_RE = Regexp.new('<meta property="article:published_time" content="(.*)"', Regexp::IGNORECASE)
    CONTENT_RE = Regexp.new('article-body-blocks">(.*?)<div id="related"', Regexp::MULTILINE)
    STRIP_TAGS_RE = Regexp.new('</?(a|span|div|img|tr|td|!--|table)[^>]*>', Regexp::IGNORECASE)
    PARA_RE = Regexp.new(/<(p|h2)[^>]*>(.*?)<\/\1>/i)

    private
    
    def date_processor
      begin
        # OPD is in GMT/UTC, which DateTime seems to use by default
        @date = Time.parse(@date)
      rescue ArgumentError
        @date = Time.now.utc
      end
    end

    def content_processor
      @content = @content.gsub(STRIP_TAGS_RE, '')
      @content = @content.scan(PARA_RE).collect { |a| a[1] }
    end
    
  end
end
