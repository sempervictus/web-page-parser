# -*- coding: utf-8 -*-
module WebPageParser

    class BbcNewsPageParserFactory < WebPageParser::ParserFactory
      URL_RE = Regexp.new("(www|news)\.bbc\.co\.uk/.+/([a-z-]+-)?[0-9]+(\.stm)?$")
      INVALID_URL_RE = Regexp.new("in_pictures|pop_ups")

      def self.can_parse?(options)
        if options[:url].match(INVALID_URL_RE)
          nil
        else
          options[:url].match(URL_RE)
        end
      end

      def self.create(options = {})
        # if options[:url].match(/sport\/\d\//)
          BbcSportsPageParserV4.new(options)
        # else
          # BbcNewsPageParserV4.new(options)
        # end
      end
    end

    # BbcNewsPageParserV1 parses BBC News web pages exactly like the
    # old News Sniffer BbcNewsPage class did.  This should only ever
    # be used for backwards compatability with News Sniffer and is
    # never supplied for use by a factory.
    class BbcNewsPageParserV1 < WebPageParser::BaseParser

      TITLE_RE = Regexp.new('<meta name="Headline" content="(.*)"', Regexp::IGNORECASE)
      DATE_RE = Regexp.new('<meta name="OriginalPublicationDate" content="(.*)"', Regexp::IGNORECASE)
      CONTENT_RE = Regexp.new('S (?:SF) -->(.*?)<!-- E BO', Regexp::MULTILINE)
      STRIP_TAGS_RE = Regexp.new('</?(div|img|tr|td|!--|table)[^>]*>',Regexp::IGNORECASE)
      WHITESPACE_RE = Regexp.new('\t|')
      PARA_RE = Regexp.new(/<p>/i)
      
      def hash
        # Old News Sniffer only hashed the content, not the title
        Digest::MD5.hexdigest(content.to_s)
      end

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
        @content = STRIP_TAGS_RE.gsub(@content, '')
        @content = WHITESPACE_RE.gsub(@content, '')
        @content = decode_entities(@content)
        @content = @content.split(PARA_RE)
      end

    end

    # BbcNewsPageParserV2 parses BBC News web pages
    class BbcNewsPageParserV2 < WebPageParser::BaseParser

      TITLE_RE = Regexp.new('<meta name="Headline" content="(.*)"', Regexp::IGNORECASE)
      DATE_RE = Regexp.new('<meta name="OriginalPublicationDate" content="(.*)"', Regexp::IGNORECASE)
      CONTENT_RE = Regexp.new('S BO -->(.*?)<!-- E BO', Regexp::MULTILINE)
      STRIP_BLOCKS_RE = Regexp.new('<(table|noscript|script|object|form)[^>]*>.*?</\1>', Regexp::IGNORECASE)
      STRIP_TAGS_RE = Regexp.new('</?(b|div|img|tr|td|br|font|span)[^>]*>', Regexp::IGNORECASE)
      STRIP_COMMENTS_RE = Regexp.new('<!--.*?-->')
      STRIP_CAPTIONS_RE = Regexp.new('<!-- caption .+?<!-- END - caption -->')
      WHITESPACE_RE = Regexp.new('[\t ]+')
      PARA_RE = Regexp.new('</?p[^>]*>', Regexp::IGNORECASE)
      
      private
      
      def content_processor
        @content = @content.gsub(STRIP_CAPTIONS_RE, '')
        @content = @content.gsub(STRIP_COMMENTS_RE, '')
        @content = @content.gsub(STRIP_BLOCKS_RE, '')
        @content = @content.gsub(STRIP_TAGS_RE, '')
        @content = @content.gsub(WHITESPACE_RE, ' ')
        @content = @content.split(PARA_RE)
      end
      
      def date_processor
        begin
          # OPD is in GMT/UTC, which DateTime seems to use by default
          @date = Time.parse(@date)
        rescue ArgumentError
          @date = Time.now.utc
        end
      end

    end

    class BbcNewsPageParserV3 < BbcNewsPageParserV2
      CONTENT_RE = Regexp.new('<div id="story\-body">(.*?)<div class="bookmark-list">', Regexp::MULTILINE)
      STRIP_FEATURES_RE = Regexp.new('<div class="story-feature">(.*?)</div>', Regexp::MULTILINE)
      STRIP_MARKET_DATA_WIDGET_RE = Regexp.new('<\!\-\- S MD_WIDGET.*? E MD_WIDGET \-\->')
      ICONV = nil # BBC news is now in utf8
      
      def content_processor
        @content = @content.gsub(STRIP_FEATURES_RE, '')
        @content = @content.gsub(STRIP_MARKET_DATA_WIDGET_RE, '')
        super
      end
    end

    class BbcNewsPageParserV4 < BbcNewsPageParserV3
      CONTENT_RE = Regexp.new('<div class=.story-body.>(.*?)<!-- / story\-body', Regexp::MULTILINE)
      STRIP_PAGE_BOOKMARKS = Regexp.new('<div id="page-bookmark-links-head".+?</div>', Regexp::MULTILINE)
      STRIP_STORY_DATE = Regexp.new('<span class="date".+?</span>', Regexp::MULTILINE)
      STRIP_STORY_LASTUPDATED = Regexp.new('<span class="time\-text".+?</span>', Regexp::MULTILINE)
      STRIP_STORY_TIME = Regexp.new('<span class="time".+?</span>', Regexp::MULTILINE)
      TITLE_RE = Regexp.new('<h1 class="story\-header">(.+?)</h1>', Regexp::MULTILINE)
      STRIP_CAPTIONS_RE2 = Regexp.new('<div class=.caption.+?</div>', Regexp::MULTILINE)
      STRIP_HIDDEN_A = Regexp.new('<a class=.hidden.+?</a>', Regexp::MULTILINE)
      STRIP_STORY_FEATURE = Regexp.new('<div class=.story\-feature.+?</div>', Regexp::MULTILINE)
      STRIP_HYPERPUFF_RE = Regexp.new('<div class=.embedded-hyper.+?<div class=.hyperpuff.+?</div>.+?</div>', Regexp::MULTILINE)
      STRIP_MARKETDATA_RE = Regexp.new('<div class=.market\-data.+?</div>', Regexp::MULTILINE)
      STRIP_EMBEDDEDHYPER_RE = Regexp.new('<div class=.embedded\-hyper.+?</div>', Regexp::MULTILINE)

      def content_processor
        @content = @content.gsub(STRIP_PAGE_BOOKMARKS, '')
        @content = @content.gsub(STRIP_STORY_DATE, '')
        @content = @content.gsub(STRIP_STORY_LASTUPDATED, '')
        @content = @content.gsub(STRIP_STORY_TIME, '')
        @content = @content.gsub(TITLE_RE, '')
        @content = @content.gsub(STRIP_CAPTIONS_RE2, '')
        @content = @content.gsub(STRIP_HIDDEN_A, '')
        @content = @content.gsub(STRIP_STORY_FEATURE, '')
        @content = @content.gsub(STRIP_HYPERPUFF_RE, '')
        @content = @content.gsub(STRIP_MARKETDATA_RE, '')
        @content = @content.gsub(STRIP_EMBEDDEDHYPER_RE, '')
        super
      end
    end
    
end
