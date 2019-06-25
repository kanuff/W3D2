

class QuestionFollow 
  attr_accessor :id, :question_id, :user_id

   def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| QuestionFollow.new(datum) }
  end

  def self.followers_for_question_id(question_id)
    data = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
    SELECT
      users.id, users.fname, users.lname
    FROM
      question_follows
      JOIN users
      ON question_follows.user_id = users.id
    WHERE
      question_follows.question_id = ?
    SQL
    data.map {|datum| User.new(datum)}
  end

  def self.followed_questions_for_user_id(user_id)
    data = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
    SELECT
      questions.id, questions.title, questions.body, questions.author 
    FROM
      question_follows 
      JOIN questions 
      ON question_follows.question_id = questions.id 
    WHERE
      question_follows.user_id = ?
    SQL
    data.map {|datum| Question.new(datum)}
  end

  def self.most_followed_questions(n)
    data = QuestionsDBConnection.instance.execute(<<-SQL, n)
    SELECT
      questions.id, questions.title, questions.body, questions.author 
    FROM
      question_follows 
      JOIN questions 
      ON question_follows.question_id = questions.id 
    GROUP BY
      question_follows.question_id
    ORDER BY
      COUNT(*) DESC
    LIMIT
      ?
    SQL
    data.map {|datum| Question.new(datum)}
  end

  
   def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

end
