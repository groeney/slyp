module ActiveSupport::Callbacks::ClassMethods
  def without_callback(*args, &block)
    skip_callback(*args)
    begin
      yield
    ensure
      set_callback(*args)
    end
  end
end