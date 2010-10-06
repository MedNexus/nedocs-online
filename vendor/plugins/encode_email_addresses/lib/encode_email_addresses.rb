module ActionView::Helpers::TextHelper
  
  # Turns all email addresses into clickable links.  If a block is given,
  # each email is yielded and the result is used as the link text.
  # Example:
  #   auto_link_email_addresses(post.body) do |text|
  #     truncate(text, 15)
  #   end
  def auto_link_email_addresses(text)
    re = %r{
            (<\w+[^<>]*?>|[\s[:punct:]]|mailto:|^) # leading text
            (
              [\w\.!#\$%\-+.]+         # username
              @
              [-\w]+                   # subdomain or domain
              (?:\.[-\w]+)+            # remaining subdomains or domain
            ) 
            ([[:punct:]]|\s|<|$)       # trailing text
           }x
    
    text.gsub(re) do
      all, a, b, c = $&, $1, $2, $3
      if a =~ /<a\s|[='"]$/i
        all
      elsif a =~ /mailto:/i
        url_src = b
        
        url = ''
        url_src.length.times do |i|
          url << (i % 2 == 0 ? sprintf("%%%x", url_src[i]) : url_src[i])
        end
        
        %{#{a}#{url}#{c}}
      else
        url_src = b
        text_src = b
        text_src = yield(text_src) if block_given?
        next unless url_src && text_src
        
        url = ''
        text = ''
        url_src.length.times do |i|
          url << (i % 2 == 0 ? sprintf("%%%x", url_src[i]) : url_src[i])
        end
        text_src.length.times do |i|
          text << (i % 4 == 0 ? '<span>' << text_src[i] << '</span>' : text_src[i])
        end
        
        %{#{a}<a href="mailto:#{url}">#{text}</a>#{c}}
      end
    end
  end
end