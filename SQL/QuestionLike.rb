require 'byebug'

class QuestionLike 
  attr_accessor :id, :question_id, :user_id

   def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM question_likes")
    data.map { |datum| QuestionLike.new(datum) }
  end

  def self.likers_for_question_id(question_id)
    data = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
    SELECT
      users.id, users.fname, users.lname
    FROM
      question_likes
      JOIN users
      ON question_likes.user_id = users.id
    WHERE
      question_likes.question_id = ?
    SQL
    data.map {|datum| User.new(datum)}
  end

  def self.num_likes_for_question(question_id)
    data = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
    SELECT
      COUNT(*) AS count
    FROM
      question_likes
    WHERE
      question_likes.question_id = ?
    GROUP BY
      question_likes.question_id
    SQL
    data.first['count']
  end
  
  def self.liked_questions_for_user_id(user_id)
    data = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
    SELECT
      questions.id, questions.title, questions.body, questions.author
    FROM
      question_likes
      JOIN questions
      ON questions.id = question_likes.question_id
    WHERE
      question_likes.user_id = ?
    SQL
    data.map {|datum| Question.new(datum)}
  end

  def self.most_liked_questions(n)
    data = QuestionsDBConnection.instance.execute(<<-SQL, n)
    SELECT
      questions.id, questions.title, questions.body, questions.author 
    FROM
      question_likes 
      JOIN questions 
      ON question_likes.question_id = questions.id 
    GROUP BY
      question_likes.question_id
    ORDER BY
      COUNT(*) DESC
    LIMIT
      ?
    SQL
    data.map {|datum| Question.new(datum)}
  end

  def initialize(options)
    @question_id = options['question_id']
    @user_id = options['user_id']
  end



end