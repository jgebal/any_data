class PLSQL::ObjectInstance
  def respond_to?(method, include_private = false)
    super(method, include_private)
  end
end
