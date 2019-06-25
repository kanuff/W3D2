


class Question 
  attr_accessor :id, :title, :body, :author 
  
  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM questions")
    data.map { |datum| Question.new(datum) }
  end

  def self.find_by_id(id)
    data = QuestionsDBConnection.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      questions
    WHERE
      id = ?
    SQL

    Question.new(data.first)
  end

  def self.find_by_author_id(author)
    data = QuestionsDBConnection.instance.execute(<<-SQL, author)
    SELECT
      *
    FROM
      questions
    WHERE
      author = ?
    SQL
    data.map { |datum| Question.new(datum) }
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author = options['author']
  end

  def author_name
    user = User.find_by_id(self.author)
    "#{user.fname} #{user.lname}"
  end

  def replies
    raise "#{self} not in database" unless self.id
    Reply.find_by_question_id(self.id)
  end

  def followers
    QuestionFollow.followers_for_question_id(self.id)
  end

  def likers
    QuestionLike.likers_for_question_id(self.id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(self.id)
  end

  def insert
    raise "#{self} already in database" if self.id
    QuestionsDBConnection.instance.execute(<<-SQL, self.title, self.body, self.author)
      INSERT INTO
        questions (title, body, author)
      VALUES
        (?, ?, ?)
    SQL
    self.id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless self.id
    QuestionsDBConnection.instance.execute(<<-SQL, self.title, self.body, self.author, self.id)      
    UPDATE
        questions
      SET
        title = ?, body = ?, author = ?
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