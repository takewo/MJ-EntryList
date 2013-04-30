require 'sqlite3'

class MJDatabase

  # Database name
  DB_NAME = 'mj-entries.db'
  
  #Table names
  ENTRY_TABLE_NAME = 'entries'
  PLAYER_TABLE_NAME = 'players'
  SHOP_TABLE_NAME = 'shops'

  # Database initialization.
  def initialize
    @db = SQLite3::Database.new(DB_NAME)
    clean
    generate
    puts "Database #{DB_NAME} initialized."
  end

  def save(entry)
    entry_id = insert_entry(entry[0], entry[6])
    insert_shop(entry[4].to_i, entry[5])
    insert_player(entry_id, entry[4].to_i, entry[1], entry[2], entry[3], entry[7])
  end

  def close
    @db.close
    puts "Database #{DB_NAME} closed."
  end

  # Clean up existing tables
  def clean
    drop_table_sql = """
      DROP TABLE IF EXISTS #{ENTRY_TABLE_NAME};
      DROP TABLE IF EXISTS #{PLAYER_TABLE_NAME};
      DROP TABLE IF EXISTS #{SHOP_TABLE_NAME};
    """
    @db.execute_batch(drop_table_sql)
    puts "Existing tables cleaned."
  end

  # Generate initial tables
  def generate
    create_entry_table = """
      CREATE TABLE #{ENTRY_TABLE_NAME} (
        id integer PRIMARY KEY AUTOINCREMENT,
        entry_number text UNIQUE,
        total_ratings text
      );
    """
    create_player_table = """
      CREATE TABLE #{PLAYER_TABLE_NAME} (
        id integer PRIMARY KEY AUTOINCREMENT,
        entry_id integer,
        shop_id integer,
        name text,
        name_phonetic text,
        ratings text,
        zero_one_stats text
      );
    """

    create_shop_table = """
      CREATE TABLE #{SHOP_TABLE_NAME} (
        id integer PRIMARY KEY,
        name text
      );
    """
    @db.execute(create_entry_table)
    @db.execute(create_player_table)
    @db.execute(create_shop_table)

    puts "Tables generated."
  end

  def insert_entry(entry_number, total_ratings) 
    if entry_exists(entry_number)
      # puts "Entry already existed. -> entry_number:#{entry_number}"
    
    else 
      insert_entry_sql = """
        INSERT INTO #{ENTRY_TABLE_NAME}
          (entry_number, total_ratings)
        VALUES
        (
          :entry_number,
          :total_ratings
        );
      """
      @db.execute(insert_entry_sql,
        :entry_number => entry_number,
        :total_ratings => total_ratings
      )
      puts "Entry created. -> entry_number:#{entry_number}, total_ratings: #{total_ratings}"
    end
    get_entry(entry_number)[0]
  end

  def get_entry(entry_number)
    find_entry_sql = """
      SELECT id
      FROM #{ENTRY_TABLE_NAME}
      WHERE entry_number = '#{entry_number}'
    """
    @db.get_first_row(find_entry_sql)
  end

  def entry_exists(entry_number)
    get_entry(entry_number).nil? ? false : true
  end

  def insert_shop(id, name)
    if shop_exists(id)
      # puts "Shop already existed. -> id:#{id}"

    else 
      insert_shop_sql = """
        INSERT INTO #{SHOP_TABLE_NAME}
          (id, name)
        VALUES
        (
          :id,
          :name
        )
      """
      @db.execute(insert_shop_sql,
        :id => id,
        :name => name
      )
      puts "Shop created. -> id:#{id}, name:#{name}"
    end
  end

  def shop_exists(id)
    existance_check_sql = """
      SELECT id
      FROM #{SHOP_TABLE_NAME}
      WHERE id = #{id}
    """
    @db.execute(existance_check_sql).empty? ? false : true
  end

  def insert_player(entry_id, shop_id, name, name_phonetic, ratings, zero_one_stats)
    insert_player_sql = """
      INSERT INTO #{PLAYER_TABLE_NAME}
        (entry_id, shop_id, name, name_phonetic, ratings, zero_one_stats)
      VALUES
      (
        :entry_id,
        :shop_id,
        :name,
        :name_phonetic,
        :ratings,
        :zero_one_stats
      )
    """
    @db.execute(insert_player_sql,
      :entry_id => entry_id,
      :shop_id => shop_id,
      :name => name,
      :name_phonetic => name_phonetic,
      :ratings => ratings,
      :zero_one_stats => zero_one_stats
    )
  end

  private :clean, :generate, :insert_entry, :entry_exists, :insert_player, :insert_shop, :shop_exists

end