require_relative "../config/environment.rb"
require 'active_support/inflector'
require "pry"

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].execute("pragma table_info('#{table_name}')").map do |row|
      row["name"]
      # binding.pry
    end
  end

  def initialize(attributes={})
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  # def values_for_insert
  #     self.class.column_names.map do |col_name|
  #       "'#{send(col_name)}'"
  #     end.reject{|x|x==''}.compact.join(", ")
  #
  # end
  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

def save
  sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
  DB[:conn].execute(sql)
  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
end

def self.find_by_name(name)
  sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
  DB[:conn].execute(sql)
end

def self.find_by(attribute)
  binding.pry
  sql = "SELECT * FROM #{self.table_name} WHERE #{attribute.keys.first} = '#{attribute.values.first}'"
  DB[:conn].execute(sql)


end


end
