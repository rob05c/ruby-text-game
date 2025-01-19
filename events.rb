require 'rubygems'
require 'algorithms'

include Containers

##
# EventQueue handles queuing and executing events.
# Events can be timed, e.g. an NPC that moves every N seconds,
# or immediate. Immediate events will simply be placed at the top of the queue.
#
# Events are ordered, e.g. an immediate event is placed behind any other events >= the current time.
#
# Note the EventQueue knows nothing about locks or thread safety.
# The event_funcs MUST lock appropriately.
#
class EventQueue
  def initialize
    # TODO: implement heap, remove dependency.
    #       A heap is a pretty simple thing to implement, not worth the cost of a dependency right now.
    @heap = MinHeap.new
    @lock = Mutex.new
    @stop = false
    @thread = nil
  end

  ##
  # start starts the event queue processing in a thread.
  def start
    @thread = Thread.new { run }
  end

  # run runs the event queue, and does not return.
  # This should typically be called by start.
  # TODO make private?
  def run
    loop do
      @lock.synchronize do
        return if @stop # if the EventQueue was stopped, stop the run

        Thread.stop if @heap.size == 0 # if the event queue is empty, pause the thread until an event is added

        next_event = @heap.min
        time_until_s = next_event.time - Time.now
        if time_until_s > 0
          @lock.sleep(time_until_s)
          # loop again, because new events may have been added
          next
        end

        puts "DEBUG calling time_until_s #{time_until_s}"

        # time was after the current time, so process it

        next_event = @heap.pop # actually remove it from the heap
        next_event.fn.call
      end
    end

    puts 'hello from thread'
  end

  ##
  # stop stops the event queue thread
  # This must be called to free resources when finished with the EventQueue.
  def stop
    @lock.synchronize do
      @stop = true
    end
  end

  def add_event(time, fn)
    @lock.synchronize do
      @heap.push(EventQueueObj.new(time, fn))
      @thread.wakeup
    end
  end
end

class EventQueueObj
  include Comparable

  attr_accessor :time
  attr_accessor :fn

  def initialize(time, fn)
    @time = time
    @fn = fn
  end

  def <=>(other)
    @time <=> other.time
  end

  def <(other)
    @time < other.time
  end

  def >(other)
    @time > other.time
  end

  def <=(other)
    @time <= other.time
  end

  def >=(other)
    @time >= other.time
  end
end
