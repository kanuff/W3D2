
class Reply 
  attr_accessor :id, :question_id, :author, :parent, :body

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_id(id)
    data = QuestionsDBConnection.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      replies
    WHERE
      id = ?
    SQL
    Reply.new(data.first)
  end

  def self.find_by_user_id(author)
    data = QuestionsDBConnection.instance.execute(<<-SQL, author)
    SELECT
      *
    FROM
      replies
    WHERE
      author = ?
    SQL
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_question_id(question_id)
    data = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
    SELECT
      *
    FROM
      replies
    WHERE
      question_id = ?
    SQL
    data.map { |datum| Reply.new(datum) }
  end

   def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @author = options['author']
    @parent = options['parent']
    @body = options['body']
  end

  def author_name       
    user = User.find_by_id(self.author)
    "#{user.fname} #{user.lname}"
  end

  def question 
    question = Question.find_by_id(self.question_id)
    "#{question.body}"
  end
  
  def parent_reply 
    raise "No parent reply!" unless self.parent 
    Reply.find_by_id(self.parent)
  end

  def child_replies
    child = find_child
    raise "No child replies" unless child
    child
  end

  def insert
    raise "#{self} already in database" if self.id
    QuestionsDBConnection.instance.execute(<<-SQL, self.question_id, self.author, self.parent, self.body)
      INSERT INTO
        replies (question_id, author, parent, body)
      VALUES
        (?, ?, ?, ?)
    SQL
    self.id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless self.id
    QuestionsDBConnection.instance.execute(<<-SQL, self.question_id, self.author, self.parent, self.body, self.id)      
    UPDATE
        replies
      SET
        question_id = ?, author = ?, parent = ?, body = ?
      WHERE
        id = ?
    SQL
  end

  def save
    if self.id
      update
    else
      insert
      en
  end



  private
  def find_child
    children = QuestionsDBConnection.instance.execute(<<-SQL)
    SELECT
      *
    FROM
      replies
    WHERE
      parent IS NOT NULL
    SQL
    children.map! { |datum| Reply.new(datum) }

    # return if reply.parent_id = self.id
    children.each do |reply|
      return reply if reply.parent == self.id
    end
    nil
  end
end


  # def find_child
  #   children = QuestionsDBConnection.instance.execute(<<-SQL, self.id)
  #   SELECT
  #     *
  #   FROM
  #     replies
  #   WHERE
  #     parent = ?
  #   SQL
  #   children.map! { |datum| Reply.new(datum) }
  # end