

class User
  attr_accessor :id, :fname, :lname

   def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end

  def self.find_by_name(fname, lname)
    data = QuestionsDBConnection.instance.execute(<<-SQL, fname, lname)
    SELECT
      *
    FROM
      users
    WHERE
      fname = ? AND lname = ?
    SQL
    data.map { |datum| User.new(datum) }
  end

  def self.find_by_id(id)
    data = QuestionsDBConnection.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      users
    WHERE
      id = ?
    SQL
    User.new(data.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions 
    raise "#{self} not in database" unless self.id
    Question.find_by_author_id(self.id)
  end

  def author_replies
    raise "#{self} not in database" unless self.id
    Reply.find_by_user_id(self.id)
  end

  def followed_questions 
    QuestionFollow.followed_questions_for_user_id(self.id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(self.id)
  end

  def average_karma 
    num_questions = authored_questions.length 
    data = QuestionsDBConnection.instance.execute(<<-SQL, self.id)
    SELECT
      COUNT(*) AS total_likes
    FROM
      question_likes
      LEFT OUTER JOIN questions
      ON questions.id = question_likes.question_id
    WHERE
      questions.author = ?
    GROUP BY
      questions.author
    SQL
    total_likes = data.first['total_likes']
    total_likes / (num_questions * 1.0)
  end

  def insert
    raise "#{self} already in database" if self.id
    QuestionsDBConnection.instance.execute(<<-SQL, self.fname, self.lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
    SQL
    self.id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless self.id
    QuestionsDBConnection.instance.execute(<<-SQL, self.fname, self.lname, self.id)      
    UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
    SQL
  end

  def save
    if self.id
      update
    else
      insert
    end
  end

end