# Hacky class to proxy the current_user to a model. This is a really bad way of
# doing this, but there's no real cleaner way.
class ProxyCurrentUser
  # Very expensive, don't run this often.
  def self.subclasses
    def self.each_subclass
      ObjectSpace.each_object(Class) { |candidate|
        yield candidate if candidate < self
      }
    end

    ret = []
    each_subclass {|c| ret << c}
    ret
  end

  def self.current_user
    Thread.current[:current_user]
  end

  def self.current_user=(usr)
    puts "!@#!@#!@#!@#!@#"
    puts usr.inspect
    Thread.current[:current_user] = usr
  end
end
