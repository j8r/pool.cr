# A simple thread-safe generic pool.
#
# A pool can be used to store resources that are expensive to create (like connections).
# [See here](https://en.wikipedia.org/wiki/Pool_(computer_science)) for more explanations.
#
# ```
# require "pool"
#
# pool = Pool.new { IO::Memory.new }
# pool.get do |resource|
#   # do something
# end
# ```
class Pool(T)
  {% if flag?(:preview_mt) %}
    @mutex = Mutex.new

    private def synchronize
      @mutex.synchronize { yield }
    end
  {% else %}
    private def synchronize
      yield
    end
  {% end %}

  # total_resources of open connections managed by this pool
  @total_resources : Set(T)
  # connections available for checkout
  @idle_resources : Deque(T)

  # Creates a new Pool.
  #
  # ```
  # require "pool"
  #
  # Pool.new { IO::Memory.new }
  # ```
  def initialize(initial_capacity : Int = 0, &@block : -> T)
    @idle_resources = Deque(T).new initial_capacity, &@block
    @total_resources = Set(T).new @idle_resources
  end

  # Adds a resource.
  def add(resource : T) : Nil
    synchronize { @idle_resources.push resource }
  end

  private def new_resource : T
    resource = @block.call
    @total_resources.add resource
    resource
  end

  # Gets a resource.
  def get : T
    synchronize { @idle_resources.shift? || new_resource }
  end

  # Gets an resource, yields, then adds it back.
  #
  # Note that if an exception was raised in the block, the resource won't be added back.
  # This behavior is used to prevent adding an invalid resource, for example a connection causing an IO error.
  def get(& : T ->) : Nil
    resource = get
    begin
      yield resource
    rescue ex
      @total_resources.delete resource
      raise ex
    else
      add resource
    end
  end

  # Returns the pool's used resources size.
  def used_size : Int32
    total_size - idle_size
  end

  # Returns the pool's idle size.
  def idle_size : Int32
    @idle_resources.size
  end

  # Returns the pool's total size.
  def total_size : Int32
    @total_resources.size
  end

  # Resizes the pool to match the new `total_size`, and yields each deleted resource on size shrinking.
  def resize(new_size : Int32, & : T ->) : Nil
    case total_size
    when .< new_size
      synchronize do
        while total_size < new_size
          @idle_resources.push new_resource
        end
      end
    when .> new_size
      synchronize do
        while total_size > new_size
          resource = @idle_resources.shift
          @total_resources.delete resource
          yield resource
        end
      end
    end
  end

  # Resizes the pool to match the new size
  def resize(new_size : Int32) : Nil
    resize(new_size) { }
  end
end
