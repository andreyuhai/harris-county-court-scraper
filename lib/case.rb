class Case
  attr_reader :case_number, :file_date, :type_desc, :subtype, :case_title, :status, :judge, :court_room, :created_by,
                :case_activities

  def initialize(created_by, **case_details)
    self.case_number = case_details[:case_number]
    self.file_date = case_details[:file_date]
    self.type_desc = case_details[:type_desc]
    self.subtype = case_details[:subtype]
    self.case_title = case_details[:case_title]
    self.status = case_details[:status]
    self.judge = case_details[:judge]
    self.court_room = case_details[:court_room]
    self.created_by = created_by
  end

  def case_number=(case_number)
    @case_number = case_number
  end

  def file_date=(file_date)
    @file_date = file_date.empty? || only_whitespace?(file_date) ? 'NULL' : "'#{Date.strptime(file_date.gsub('/', '-'), '%m-%d-%Y')}'"
  end

  def type_desc=(type_desc)
    @type_desc = type_desc.empty? || only_whitespace?(type_desc) ? 'NULL' : "'#{escape_single_quotes(type_desc)}'"
  end

  def subtype=(subtype)
    @subtype = subtype.empty? || only_whitespace?(subtype) ? 'NULL' : "'#{escape_single_quotes(subtype)}'"
  end

  def case_title=(case_title)
    @case_title = case_title.empty? || only_whitespace?(case_title) ? 'NULL' : "'#{escape_single_quotes(case_title)}'"
  end

  def status=(status)
    @status = status.empty? || only_whitespace?(status) ? 'NULL' : "'#{escape_single_quotes(status) }'"
  end

  def judge=(judge)
    @judge = judge.empty? || only_whitespace?(judge) ? 'NULL' : "'#{escape_single_quotes(judge)}'"
  end

  def court_room=(court_room)
    @court_room = court_room
  end

  def created_by=(created_by)
    @created_by = "'#{created_by}'"
  end

  def case_activities=(case_activities)
    case_activities.each do |activity|
      activity[:date] = activity[:date].empty? || only_whitespace?(activity[:date]) ? 'NULL' : "'#{Date.strptime(activity[:date].gsub('/', '-'), '%m-%d-%Y')}'"
      activity[:case_activity] = activity[:case_activity].empty? || only_whitespace?(activity[:case_activity]) ? 'NULL' : "'#{escape_single_quotes(activity[:case_activity])}'"
      activity[:comments] = activity[:comments].empty? || only_whitespace?(activity[:comments]) ? 'NULL' : "'#{escape_single_quotes(activity[:comments])}'"
    end
    @case_activities = case_activities
  end

  # Checks whether a string consists of only whitespaces.
  # @param [String] string to check
  # @return [Boolean]
  def only_whitespace?(string)
    string.match?(/\A[[:space:]]*\z/)
  end

  # Returns a string of all the parameters that is going to be used in an INSERT query to insert a case.
  # @return [String]
  def case_values
    "#{@case_number}, #{@file_date}, #{@type_desc}, #{@subtype}, #{@case_title}, #{@status}, #{@judge}, #{@court_room}, #{@created_by}"
  end

  # Returns a string of all the parameters that is going to be used in an INSERT query to insert a case detail.
  # @param [Hash] activity
  # @return [String]
  def case_activity_values(activity)
    "#{@case_number}, #{activity[:date]}, #{activity[:case_activity]}, #{activity[:comments]}, #{@created_by}"
  end

  # Escapes single quotes in a string to be able to use it in an INSERT query.
  # @param [String] string
  # @return [String] single quotes escaped string
  def escape_single_quotes(string)
    string.gsub("'", "\\\\'")
  end
end