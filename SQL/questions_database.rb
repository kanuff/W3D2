require 'sqlite3'
require 'singleton'
require_relative 'Question'
require_relative 'QuestionFollow'
require_relative 'QuestionLike'
require_relative 'User'
require_relative 'Reply'

class QuestionsDBConnection < SQLite3::Database  
  include Singleton 

  def initialize 
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end
