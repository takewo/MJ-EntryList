# coding: utf-8
require 'nokogiri'
require 'open-uri'
require 'kconv'
require './MJDatabase'

db = MJDatabase.new

# URI to MJ Darts Tournament Player Entry Page
uri = 'http://www.mjs-co.net/pdf/mj13sp/12th_db.htm'

# Link destination is encoded by Shift_JIS
# As first you should convert to UTF-8 and then parse it.
doc = Nokogiri::HTML(open(uri).read.toutf8, nil, 'utf-8')

doc.search("table > tr").each_with_index do | e, i |
  # We dont need data until line 4
  if i >= 4
    # 1. Convert full space -> half space
    # 2. Make array by splitting with break line mark
    # 3. Remove spaces in front or back
    # 4. Remove empty column
    entry_row = e.children.map { | c | 
      unless c.inner_html.empty?
        c.inner_text.gsub("\n", '').gsub('　', ' ').gsub('  ', ' ').strip
      end
    }.reject{|v| v.nil? || v.empty?}

    if i == 4
      # entry is header
    elsif entry_row.length == 8
      db.save(entry_row)
    end
  end
end

db.close
