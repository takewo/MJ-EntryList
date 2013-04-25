# coding: utf-8
require 'nokogiri'
require 'open-uri'
require 'kconv'

# URI to MJ Darts Tournament Player Entry Page 
uri = 'http://www.mjs-co.net/pdf/mj13sp/12th_db.htm'

# Link destination is encoded by Shift_JIS
# As first you should convert to UTF-8 and then parse it.
doc = Nokogiri::HTML(open(uri).read.toutf8, nil, 'utf-8')

doc.search("#12th_db_1251 > table > tr").each_with_index do | e, i |
  # We dont need data until line 4
  if i >= 4 then
    # 1. Convert full space -> half space
    # 2. Make array by splitting with break line mark
    # 3. Remove spaces in front or back
    # 4. Remove empty column
    entry = e.content.gsub('　', ' ').split("\n").map{|value| value.strip}.reject{|value| value.empty?}
  	p entry
  end
end
