require 'mysql2'

class Database
  attr_reader :client

  def initialize(db_username, db_password, db_name, host = 'localhost')
    @client = Mysql2::Client.new(username: db_username, password: db_password, database: db_name, host: host)
  end

  # Creates a table for cases
  # @param [String] table_name
  def create_case_table(table_name)
    statement = <<-END_SQL.gsub(/\s+/, " ").strip
    CREATE TABLE IF NOT EXISTS #{table_name} (
      id INT AUTO_INCREMENT,
      case_number INT,
      file_date DATE,
      type_desc VARCHAR(256),
      subtype VARCHAR(256),
      case_title VARCHAR(256),
      status VARCHAR(256),
      judge VARCHAR(256),
      court_room INT,
      created_by VARCHAR(100),
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (id)
    )
    END_SQL
    @client.query statement
  end

  # Creates a table for case activities
  # @param [String] table_name
  def create_case_activity_table(table_name)
    statement = <<-END_SQL.gsub(/\s+/, " ").strip
    CREATE TABLE IF NOT EXISTS #{table_name} (
      id INT AUTO_INCREMENT,
      case_number VARCHAR(300),
      date DATE,
      case_activity VARCHAR(300),
      comments VARCHAR(300),
      created_by VARCHAR(100),
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (id)
    )
    END_SQL
    @client.query statement
  end

  # Inserts a case into case table
  # @param [String] table_name
  # @param [String] case_values
  def insert_case(table_name, case_values)
    statement = <<-END_SQL.gsub(/\s+/, " ").strip
    INSERT INTO #{table_name}(case_number, file_date, type_desc, subtype, case_title, status, judge, court_room, created_by)
    VALUES(#{case_values})
    END_SQL
    @client.query statement
  end

  # Inserts a case activity into case activity table
  # @param [String] table_name
  # @param [String] activity_values
  def insert_case_activity(table_name, activity_values)
    statement = <<-END_SQL.gsub(/\s+/, " ").strip
    INSERT INTO #{table_name}(case_number, date, case_activity, comments, created_by)
    VALUES(#{activity_values})
    END_SQL
    @client.query statement
  end
end