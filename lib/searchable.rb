require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    query_params = params.keys
      .map { |key| "#{key}=?" }.join(" AND ")

    query = <<-SQL
      SELECT *
      FROM #{table_name}
      WHERE #{query_params}
    SQL

    results = DBConnection.execute(query, *params.values)
    parse_all(results)
  end
end
