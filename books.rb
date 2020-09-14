require 'goodreads'
require 'airtable'

goodreads_api_key = 'FILL_IN'
airtable_api_key = 'FILL_IN'
table_id = 'FILL_IN'
table_name = 'Books'
recommender_table_name = 'Recommender'
author_table_name = 'Author'

# to run the program in Terminal: ruby books.rb ISBN "recommender" tags
new_book = { isbn: ARGV[0], recommender: ARGV[1], tags: ARGV[2].split(',') }

def clean_desc(text)
  text.gsub(/<\/?[a-z]*\s?\/?>/,'')
end

def get_name_record(table, name)
  existing_rec_check = 'IF(Name = "' + name + '", 1, 0)'
  existing_rec_search = table.select(formula: existing_rec_check)
  if existing_rec_search.empty?

    new_entry = Airtable::Record.new(:Name => name)
    # p new_entry
    new_book_person_id = table.create(new_entry)[:id]
    record_type = "new"
  else
    new_book_person_id = existing_rec_search.first[:id]
    record_type = "existing"
  end
  [new_book_person_id, record_type]
end

def get_shelves(goodreads_book)
  shelves = []

  goodreads_book.popular_shelves.first[1].each { |shelf|
    shelves << shelf.name unless ["to-read", "currently-reading", "non-fiction", "nonfiction", "favourites", "favorites"].include?(shelf.name)
  }

  shelves = shelves.join(',')
  shelves
end

# Start Goodreads client
goodreads_client = Goodreads.new(api_key: goodreads_api_key)

# Start Airtable processing
airtable_client = Airtable::Client.new(airtable_api_key)
table = airtable_client.table(table_id, table_name)
@recommender_table = airtable_client.table(table_id, recommender_table_name)
@author_table = airtable_client.table(table_id, author_table_name)

# Create new record
book = goodreads_client.book_by_isbn(new_book[:isbn])

table_book_id, book_type = get_name_record(table, book.title)
book_record = table.find(table_book_id)
# p book_record

if book_type == "new"

  book_record["Cover"] = [:url => book.image_url]
  book_record["Goodreads"] = book.link
  book_record["Tags"] = new_book[:tags]
  book_record["Shelves"] = get_shelves(book)
  book_record["Status"] = "to read"
  book_record["Notes"] = clean_desc(book.description)
  book_record["GR_Rating"] = book.average_rating.to_f
  book_record["GR_Ratings_Count"] = book.work.ratings_count
  book_record["Recommender"] = [get_name_record(@recommender_table, new_book[:recommender])[0]]

  book_record["Author"] = []

  if book.authors.author.class == Array
    book.authors.author.each { |author|
      book_record["Author"] << get_name_record(@author_table, author.name)[0]
    }
  else
    book_record["Author"] << get_name_record(@author_table, book.authors.author.name)[0]
  end

else
  book_record["Recommender"] << get_name_record(@recommender_table, new_book[:recommender])[0]
  book_record["GR_Rating"] = book.average_rating.to_f
  book_record["GR_Ratings_Count"] = book.work.ratings_count

end
result = table.update(book_record)

puts "Record submission:"
puts result.inspect

# ******************************

# For historic books
# records = table.all
# records.each { |existing_record|
# # existing_record = table.find("recuktrJR5vM4Y0dE")

#   # if !existing_record["Shelves"].present?
#     goodreads_book = goodreads_client.book_by_title(existing_record["Name"])

#     existing_record["Goodreads"] = goodreads_book.link
#     existing_record["Cover"] = [:url => goodreads_book.image_url] unless existing_record["Cover"].present?
#     existing_record["Notes"] = clean_desc(goodreads_book.description) if goodreads_book.description.present?
#     existing_record["GR_Rating"] = goodreads_book.average_rating.to_f
#     existing_record["GR_Ratings_Count"] = goodreads_book.work.ratings_count
    
#     shelves = []

#     goodreads_book.popular_shelves.first[1].each { |a|
#       shelves << a.name unless ["to-read", "currently-reading", "non-fiction", "nonfiction", "favourites", "favorites"].include?(a.name)
#     }
#     shelves = shelves.join(',')
#     existing_record["Shelves"] = shelves

#     existing_record["Author"] = []

#     if goodreads_book.authors.author.class == Array
#       goodreads_book.authors.author.each { |author|
#         existing_record["Author"] << get_name_record(@author_table, author.name)[0]
#       }
#     else
#       existing_record["Author"] << get_name_record(@author_table, goodreads_book.authors.author.name)[0]
#     end

#     a = table.update(existing_record)
#     p a
#     puts existing_record.inspect
#   # end

# # }

# ******************************

# Issues
# Can't add Popularity columns that sums the numbers of Recommenders per book without the script screwing up