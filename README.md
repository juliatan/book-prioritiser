# Personal book tracker on Airtable, using Goodreads
This project was conceived because I realised a few years ago, that I was not ever going to be able to read all the books I had added to my "to read" list. I therefore wanted a way to prioritise the books I should be reading, based on recommendations from the greatest minds and leaders in our society.

This project involves the logging of books (and who recommended them) via the console, the saving of books to an [Airtable](https://airtable.com/), and the pulling in of the books' data from [Goodreads](https://goodreads.com). Based on the number of recommenders and the ratings of each book, you can sort the books in your list to give you a better sense of how best to prioritise your reading list.

## Requirements
- Some of the technologies imported and used:
  - `goodreads` Ruby wrapper
  - `airtable` Ruby client

## App features
- Multiple `StackNavigator`s through React Navigation.
- Login screen (mostly just to practice navigating through multiple screens).
- Search screen that displays 10 results. Scrolling down loads more results.
- Clear button to clear search results.
- Redux for async state management, including persisted states. I've also included Redux Thunk for Middleware management.

## Getting started
- Install [Airtable](https://github.com/Airtable/airtable-ruby) and [Goodreads](https://github.com/sosedoff/goodreads) clients for Ruby.
- Sign up for a [Goodreads](https://goodreads.com) API key and [Airtable](https://airtable.com/) API key. Fill in rows 4-6 in `books.rb`. Create 3 Airtable tables (see rows 6-9 and amend as necessary).
- To run the program in Terminal, type in: `ruby books.rb ISBN "recommender" tags` (where `recommender` is replaced with the name of who recommended the book e.g. `Tim Ferriss`. `tags` should be a comma separated string e.g. `psychology,self-improvement`)
- The code file also includes some commented out code for anyone who wants to backfill book titles already added to their Airtable, with data from Goodreads.

## To do
- Perhaps refactor into classes?
- Scrape https://www.booksoftitans.com/list/ to find all recommenders
- Update ratings with an on-demand script

## Issues
- I can't seem add "Popularity" columns that sums the numbers of Recommenders per book without the script screwing up.