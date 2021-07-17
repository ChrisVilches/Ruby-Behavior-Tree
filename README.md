# Behavior Tree

[![Travis CI](https://api.travis-ci.com/FeloVilches/Ruby-Behavior-Tree.svg?branch=main)](https://travis-ci.org/github/FeloVilches/Ruby-Behavior-Tree) [![Gem Version](https://badge.fury.io/rb/behavior_tree.svg)](https://rubygems.org/gems/behavior_tree)

A robust and customizable Ruby gem for creating Behavior Trees, used in games, AI, robotics, and more.

<p align="center">
  <img src="https://github.com/FeloVilches/ruby-behavior-tree/blob/main/assets/logo.png?raw=true" />
</p>

## Quick start

Add this line to your application's Gemfile:

```ruby
gem 'behavior_tree'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install behavior_tree

### Build your first tree

Require the gem if necessary:

```ruby
require 'behavior_tree'
```

Create a tree using the DSL:

```ruby
my_tree = BehaviorTree::Builder.build do
  sequence do
    task {
      puts "I'm a task!"
      status.success!
    }
    condition ->(context) { context[:some_value] < 200 } do
      task {
        context[:some_value] += 1
        status.success!
      }
    end
    task { context[:some_value] > 100 ? status.failure! : status.success! }
  end
end

my_tree.print
# Output:
# ∅
# └─sequence success (0 ticks)
#       ├─task success (0 ticks)
#       ├─condition success (0 ticks)
#       │     └─task success (0 ticks)
#       └─task success (0 ticks)
```

Later in the guide you'll learn how to add your own custom classes so they are available inside the DSL as well.

If the tree or part of it cannot be built using the DSL, you can build it using plain old Ruby objects like so:

```ruby
# Initialize an empty sequence.
sequence = BehaviorTree::Sequence.new

# Creating some tasks. You can also create tasks by extending BehaviorTree::Task,
# keep reading to learn how.
task1 = BehaviorTree::Task.new {
  puts 'Hello world'
  status.success!
}

task2 = BehaviorTree::Task.new {
  puts 'Another simple task'
  status.success!
}

# Add as children.
sequence << task1
sequence << task2

# Finally build the tree.
another_tree = BehaviorTree::Tree.new sequence

another_tree.print
# Output:
# ∅
# └─sequence success (0 ticks)
#       ├─task success (0 ticks)
#       └─task success (0 ticks)
```

You can join trees created with any of the above methods (DSL or plain old Ruby objects). Let's join both of the trees we just created:

```ruby
sequence << my_tree

another_tree.print
# Output:
# ∅
# └─sequence success (0 ticks)
#       ├─task success (0 ticks)
#       ├─task success (0 ticks)
#       └─sequence success (0 ticks)
#             ├─task success (0 ticks)
#             ├─condition success (0 ticks)
#             │     └─task success (0 ticks)
#             └─task success (0 ticks)
```

Finally, let's tick the tree to put it into motion.

```ruby
# We need to assign the initial context data first.
another_tree.context = { some_value: 5 }

200.times { another_tree.tick! }

another_tree.print
# Output:
# ∅
# └─sequence failure (200 ticks)
#       ├─task success (200 ticks)
#       ├─task success (200 ticks)
#       └─sequence success (200 ticks)
#             ├─task success (200 ticks)
#             ├─condition failure (200 ticks)
#             │     └─task success (195 ticks)
#             └─task success (195 ticks)
```

## Learn how to use

- [Quick start](#quick-start)
  * [Build your first tree](#build-your-first-tree)
- [Learn how to use](#learn-how-to-use)
- [Basics](#basics)
  * [Ticking the tree](#ticking-the-tree)
  * [Node status](#node-status)
  * [Storage](#storage)
    + [Global context](#global-context)
    + [Per-node storage](#per-node-storage)
  * [Types of nodes](#types-of-nodes)
    + [Task nodes](#task-nodes)
    + [Control nodes](#control-nodes)
    + [Decorators and condition nodes](#decorators-and-condition-nodes)
- [Create custom nodes](#create-custom-nodes)
  * [Custom task](#custom-task)
  * [Custom control node](#custom-control-node)
  * [Custom decorator](#custom-decorator)
  * [Custom condition](#custom-condition)
- [Node API](#node-api)
  * [Status](#status)
  * [tick!](#tick-)
  * [halt!](#halt-)
  * [Status related callbacks and hooks](#status-related-callbacks-and-hooks)
- [Add custom nodes to the DSL](#add-custom-nodes-to-the-dsl)
- [Troubleshoot and debug your trees](#troubleshoot-and-debug-your-trees)
  * [Detecting cycles](#detecting-cycles)
  * [Checking nodes are all unique objects](#checking-nodes-are-all-unique-objects)
  * [Visualize a tree](#visualize-a-tree)
- [Miscellaneous](#miscellaneous)
  * [Generate random trees](#generate-random-trees)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)

## Basics

What is a behavior tree? According to the [Wikipedia](https://en.wikipedia.org/wiki/Behavior_tree_(artificial_intelligence,_robotics_and_control)):

> A behavior tree is a mathematical model of plan execution used in computer science, robotics, control systems and video games. They describe switchings between a finite set of tasks in a modular fashion. Their strength comes from their ability to create very complex tasks composed of simple tasks, without worrying how the simple tasks are implemented.

In simple words, it's a modular way to describe your program's control flow, in a very flexible and scalable way. It avoids the common pitfalls of usual control flow (i.e. `if-else`), such as spaghetti code, by structuring the logic as a tree, with branches (conditionals, sequence of tasks, etc) and leaf nodes (tasks to be executed).

### Ticking the tree

```ruby
my_tree.tick!

# Effects are propagated down the tree.
```

### Node status

Each node has a status, which can have three possible values:

1. `success` which is usually returned by a task when it completes successfully, by conditional nodes when the condition they evaluate is true, or when nodes have never been set to run. Since this is the default status of all nodes, a node is in `success` status if it has never been ticked, or if it has been halted (using `halt!`).
2. `running` which is returned by nodes that are currently executing.
3. `failure` which is returned to signal that execution failed.

Each type of node has different logic for returning these three values.

### Storage

#### Global context

Just like you would have access to local variables inside an `if-else` block, a behavior tree has a data structure called `context` which it can operate on. If this didn't exist, there would be no data to work with, and/or use to take decisions. In other implementations, it's called *blackboard*, a concept which refers to a global memory.

You can use any Ruby object as context, but the easiest way to get started is to pass a `Hash` object.

This example shows how to initialize a tree's context with an empty `Hash`, and when assigning it, the tree will propagate the object to all nodes of the tree.

```ruby
my_tree.context = {}
```

The method `context` is available on all nodes, which provides a reference to this object.

#### Per-node storage

Arbitrary data can also be stored on a per node basis.

```ruby
node_instance[:arbitrary_variable] = :hello_world
```

The preferred way to store node-scoped data is to use vanilla Ruby `@instance_variables`, but this is only possible if you are creating a custom class, and if the node manipulates its own data. Instead, a parent node may use this mechanism to manipulate its children data when necessary.

**Note:** `node_instance` is **not** a `Hash` object, but instead a Node object. This is a `[]` and `[]=` operator overload.

### Types of nodes

#### Task nodes

A task node is the only type of leaf node, and it usually executes an arbitrary procedure.

Tasks would usually return `success` or `failure` when they complete, and return `running` if they haven't completed yet.

**Example #1: Custom task class**

```ruby
class DecreaserTask < BehaviorTree::Task
  def on_tick
    context[:my_number] -= 1
    status.success!
  end
end
```

Learn [how to register your custom nodes](#add-custom-nodes-to-the-dsl) so they become available in the DSL.

**Example #2: Insert inline logic in the DSL**

```ruby
BehaviorTree::Builder.build do
  task do
    context[:my_number] -= 1
    status.success!
  end
end
```

#### Control nodes

A control node decides the flow of the execution. In simpler words, it uses a certain logic to decide which branch to execute. This is where most of the similarities with a simple `if-else` come from.

A control node cannot be a leaf (i.e. it must have children).

There are two types of control nodes, and custom ones can be easily created ([see examples of custom control nodes](#custom-control-node)).

1. **Sequence:**
  a. Begins executing the first child node.
  b. If the child returns `running`, the sequence also returns `running`.
  c. If child returns `failure`, all children are halted, and the sequence returns `failure`.
  d. If the child returns `success`, it continues with the next child node executing the same logic.
2. **Selector:**
  a. Begins executing the first child node.
  b. If the child returns `running`, the sequence also returns `running`.
  c. If child returns `success`, halt all children and return `success`.
  d. If child returns `failure`, then continue with the next child.
  e. If no node ever returned `success`, then return `failure`.

[Learn about "halting nodes" and what it means.](#halt-)

When a control node is ticked, by default it traverses children and ticks them using this logic:

1. If at least one node is `running`, then begin from that one, in order.
2. If no node is `running`, then traverse all nodes starting from the first one, in order.

**Example #1: Creating a sequence and a selector**

```ruby
sequence = BehaviorTree::Sequence.new
selector = BehaviorTree::Selector.new

3.times { sequence << BehaviorTree::Task.new }
2.times { selector << BehaviorTree::Task.new }

# Make the selector a child of the sequence
sequence << selector

my_tree = BehaviorTree::Builder.build do
  chain sequence
end

my_tree.print
# Output:
# ∅
# └─sequence success (0 ticks)
#       ├─task success (0 ticks)
#       ├─task success (0 ticks)
#       ├─task success (0 ticks)
#       └─selector success (0 ticks)
#             ├─task success (0 ticks)
#             └─task success (0 ticks)
```

#### Decorators and condition nodes

A decorator can have only one child, and acts as a modifier for its child.

By default the decorator nodes present in this library are:

| Name | Class | DSL | Description |
| --- | --- | --- | --- |
| Condition | `BehaviorTree::Decorators::Condition` | `condition` or `cond` | Ticks its child only if the condition succeeds. If not, returns `failure` (and has no effect whatsoever on the child). If the condition succeeds, it ticks the child and returns its status. |
| Force Failure | `BehaviorTree::Decorators::ForceFailure` | `force_failure` | Ticks the child, and always returns `failure` regardless of what the child returned. |
| Force Success | `BehaviorTree::Decorators::ForceSuccess` | `force_success`| Ticks the child, and always returns `success` regardless of what the child returned. |
| Inverter | `BehaviorTree::Decorators::Inverter` | `inverter` or `inv` | Returns `running` if the child returns `running`, and returns the opposite (inverted status) when the child returns `failure` or `success`. |
| Repeater | `BehaviorTree::Decorators::Repeater` | `repeater` or  `rep` | Ticks the child again N times while it's returning `success`. |
| Retry | `BehaviorTree::Decorators::Retry` | `re_try` | Ticks the child again N times while it's returning `failure`. |

**Example #1: Creating a tree with some decorators**

```ruby
my_tree = BehaviorTree::Builder.build do
  inv {
    sel {
      task -> { puts 'Task 1' }
      force_failure { task -> { puts 'Task 2' } }
      task -> { puts 'Task 3' }
    }
  }
  task
end
```

## Create custom nodes

### Custom task

There are two main ways to create tasks.

1. By instantiating `BehaviorTree::TaskBase` (or its alias `BehaviorTree::Task`) and passing a lambda or block.
2. By subclassing `BehaviorTree::TaskBase` and overriding the `on_tick` method with the desired procedure to execute.

Let's see examples of both.

**Example #1 Empty task (i.e. does nothing)**

```ruby
task = BehaviorTree::TaskBase.new
```

**Example #2 Task that returns status based on the context**

```ruby
task = BehaviorTree::TaskBase.new do
  if context[:a] > 1
    status.success!
  elsif context[:a] < -1
    status.failure!
  else
    status.running!
  end

  context[:a] += 1
end

# Initialize context.
task.context = { a: -2 }

task.tick!; task.status #=> failure
task.tick!; task.status #=> running
task.tick!; task.status #=> running
task.tick!; task.status #=> running
task.tick!; task.status #=> success
task.tick!; task.status #=> success
```

**Example #3: Same as #2, but using lambdas instead**

When using lambdas instead of normal `Proc` (or blocks), you must pass the `context` and `node` arguments if you want to access their data. Both parameters are optional.

```ruby
task = BehaviorTree::TaskBase.new -> (context, node) {
  if context[:a] > 1
     # 'node' is the 'self' node (i.e. the task node).
    node.status.success!
  elsif context[:a] < -1
    node.status.failure!
  else
    node.status.running!
  end

  context[:a] += 1
}
```

**Example #4: Create a custom task class**

In this task not only we override the `on_tick` method, but also the constructor, and now this task needs a parameter to be instantiated.

```ruby
class CustomTaskWithConstructorArgument < BehaviorTree::Task
  def initialize(inc)
    super()
    @inc = inc
  end

  def on_tick
    context[:a] += @inc
    context[:a].even? ? status.success! : status.running!
  end
end

task = CustomTaskWithConstructorArgument.new(3)

initial_context = { a: 3 }

task.context = initial_context

task.tick!

task.status.to_sym # => :success

initial_context # => {:a=>6}
```

### Custom control node

Control nodes use a concept called `traversal strategy`, which refers to the way the nodes are iterated.

The default strategy (named `prioritize_running`) is to:
1. If there's at least one child running, then begin (or actually, resume) from there, and in order.
2. If no child is running, then traverse all nodes starting from the first one, in order.

In order to change the strategy used by a class, you must execute (inside the class, not instance) the method `children_traversal_strategy`, and specify which strategy to use. The strategy is simply the name of a method that returns an `Enumerable` (an array, etc). This `Enumerable` must have the children to traverse.

Not executing `children_traversal_strategy` will make your class use the default strategy (i.e. `prioritize_running`).

**Example #1: Shuffle (random) traversal**

In this example, the `Shuffle` class changes only the traversal strategy, but doesn't change the way `Sequence` works. In other words, this is a sequence with random order.

```ruby
class Shuffle < BehaviorTree::Sequence
  children_traversal_strategy :shuffle

  private

  # Memoize shuffled order. Keep the same order while the sequence is running.
  def shuffle
    @shuffled_order ||= @children.shuffle
    running_idx = @shuffled_order.find_index { |node| node.status.running? }.to_i

    @shuffled_order[running_idx..]
  end

  # Un-memoize the shuffled order so that it's
  # shuffled again (everytime the status goes from not-running to running).
  def on_started_running
    @shuffled_order = nil
  end
end
```

**Example #2: Overriding the control flow logic**

The example above defines a new traversal strategy, but keeps the same logic as a vanilla `Sequence`. In the following example, we continue to use the strategy defined above, but create a different control flow logic.

Control nodes execute their control flow logic in the `on_tick` method, so this is the method that must be overriden.

```ruby
# Return success if all either succeeded or failed. Otherwise return failure.
# (Similar to other control nodes, return running when a child is running.)
class AllOrNothing < ControlNodeBase
  children_traversal_strategy :shuffle

  def on_tick
    success_count = 0
    fail_count = 0

    # This loop iterates children using the shuffle strategy, AND ticks each child.
    tick_each_children do |child|
      return status.running! if child.status.running?

      # Regardless of whether the child succeeded or failed,
      # continue with the next child. Just store whether it succeeded or not.
      success_count += 1 if child.status.success?
      fail_count += 1 if child.status.failure?

      # Can be optimized to return failure as soon as it encounters at least one
      # that failed and at least one that succeeded.
    end

    # Set self node and all children to success.
    halt!

    # Status is already success from the halt! above. Do nothing.
    return if success_count == children.count || fail_count == children.count

    # Else return fail. Results are not "all success" or "all failure".
    status.failure!
  end

  # From here it's omitted. Copy code from example above.

  def shuffle
    # ...
  end

  def on_started_running
    # ...
  end
end
```

Note that under the hood, `tick_each_children` uses the strategy defined (i.e. `shuffle` method), and traverses its children while also ticking them. You don't need to send `tick!` manually to the child. The code defined in `on_tick` is executed *right after* the child is ticked.

### Custom decorator

**Note:** Condition nodes are also a type of decorator, but they are covered separately here: [Custom condition nodes](#custom-condition).

Here's an example of how to create a custom decorator. Simply inherit from `BehaviorTree::Decorators::DecoratorBase` and override any or both of these two methods, `decorate` and `status_map`.

```ruby
class CustomDecorator < BehaviorTree::Decorators::DecoratorBase
  protected

  def decorate
    # Additional logic to be executed when the node is ticked.
  end

  # This method must change the self node status in function
  # of the child status. The default behavior is to copy its status.
  # The status is mapped at the end of the tick lifecycle.
  def status_map
    self.status = child.status
  end
end
```

### Custom condition

Creating a condition as a class. The `should_tick?` method must be overriden, and it must return a `boolean` value.

```ruby
class CustomCondition < BehaviorTree::Decorators::Condition
  def should_tick?
    context[:a] > -1
  end
end
```

Or using inline logic in the DSL. When using the DSL, before starting the block (i.e. where the child is defined), you must pass a `lambda` which receives two parameters (both optional), `context` and `node` (the `self` of the condition node).

```ruby
my_tree = BehaviorTree::Builder.build do
  condition ->(context, node) { context[:a].positive? } do
    task # The decorated task (condition node's child)
  end
end

# Define tree's context data.
my_tree.context = { a: -1 }

# Tick the tree once.
my_tree.tick!

# Inspect the tree. Condition failed, and task node hasn't been touched.
my_tree.print
# Output:
# ∅
# └─condition failure (1 ticks)
#       └─task success (0 ticks)
```

**Note:** Other behavior tree implementations prefer the use of `sequence` control nodes, and placing conditional nodes as a leaves, but with the role of simply returning `failure` or `success`. Since sequences execute the next node only if the previous one succeeded, this also works as a conditional node. In this implementation, however, both patterns are available and you are free to choose which one to use.

## Node API

### Status

Every instance of node classes have a status object, where you can execute the following methods.

**Setters**

```ruby
node.status.running!
node.status.success!
node.status.failure!

node.status = other_node.status # Copy status from other node
```

**Querying status**

```ruby
node.status.running? # => boolean
node.status.success? # => boolean
node.status.failure? # => boolean
```

**Accessing previous status**

The previous status is also stored inside a node. It can be used in `on_status_change` to trigger a certain action in function of the current and previous state (See: [Status related callbacks and hooks](#status-related-callbacks-and-hooks)).

```ruby
node.status.success!

node.status.running!

node.status.to_sym # => :running

node.prev_status.to_sym # => :success
```

**Warning:** Don't modify the `prev_status` manually. It's updated automatically.

### tick!

As you have seen in other examples, all nodes have a `tick!` method, which as the name says, ticks the node, and propagates it down to its children (if any).

The first thing it does is always setting the node to `running`. After this, what happens depends on the type of node. You can learn more about each node type and how to override their behavior in: [Create custom nodes](#create-custom-nodes).

### halt!

This simply sets the node to `success`, and when a node has children, it executes `halt!` on all children as well, which propagates the `halt!` action down the tree.

This method is usually used when you want to reset the node and its children's status. In control nodes, since they follow the strategy of *"resume from the running nodes, if there is any"* is used by default, it's imperative to execute `halt!` once the sequence/selector has finished, so it can start again from the first node (unless you override this logic in a custom control node). Other than that, you may decide not to halt them if it's not necessary.

### Status related callbacks and hooks

**on_status_change**

This method is executed everytime the node status changes. It's only triggered when there's a change (i.e. previous value and next value are different).

Therefore, the following code only triggers the callback once:

```ruby
# Current status is success.
node.status.success? # => true

node.status.failure! # Triggers the callback.
node.status.failure! # Does not trigger.
node.status.failure!
```

```ruby
class RandomStatusTask < BehaviorTree::Task
  def on_tick
    puts 'Being ticked...'
    possible_status = [:running, :success, :failure]
    status.send("#{possible_status.sample}!")
  end

  def on_status_change
    prev = prev_status
    curr = status

    puts "My status went from #{prev.to_sym} to #{curr.to_sym} (tick_count = #{tick_count})"
  end
end

task = RandomStatusTask.new

5.times { task.tick! }

# Output:
# My status went from success to running (tick_count = 1)
# Being ticked...
# My status went from running to failure (tick_count = 1)
# My status went from failure to running (tick_count = 2)
# Being ticked...
# My status went from running to failure (tick_count = 2)
# My status went from failure to running (tick_count = 3)
# Being ticked...
# My status went from running to success (tick_count = 3)
# My status went from success to running (tick_count = 4)
# Being ticked...
# My status went from running to success (tick_count = 4)
# My status went from success to running (tick_count = 5)
# Being ticked...
# My status went from running to failure (tick_count = 5)
```

In the output of the example above, one thing to note is that the first line (change from `success` to `running`) happens because `tick!` **immediately and always** sets the node to `running`. This happens even before the task logic (`on_tick` method) has been executed.

The second line of the output is the `puts` of the actual task logic. The third line happens as a result of the task logic changing the status, therefore triggering a `on_status_change` call.

**on_started_running**

Similar to `on_status_change`, but only triggers when the node has been set to `running`.

**on_finished_running**

Similar to `on_status_change`, but only triggers when the node has been set to a status other than `running`.

## Add custom nodes to the DSL

You can register new nodes to be used in the DSL, take for example the following code:

```ruby
BehaviorTree::Builder.register(
  :my_control_node,
  'CustomNodes::MyControlNode',
  children: :multiple
)
```

When using `BehaviorTree::Builder#register`, you must supply three arguments, the keyword to be used in the DSL, the class name, and an optional parameter indicating how many children your node must have.

The possible values for the `children:` argument are:

1. `none` when your node is a leaf node (i.e. task). Default value if not specified.
2. `multiple` when your node is a control node.
3. `single` when your node is a decorator, conditional, etc.

Next, you can use the registered node in the DSL.

```ruby
BehaviorTree::Builder.build do
  my_control_node do
    # The rest of the tree here.
  end
end
```

You can also define an alias for your node:

```ruby
# First argument is original key (existing one).
# Second argument is the new alias.
BehaviorTree::Builder.register_alias(:my_control_node, :my_ctrl_node)
```

This way, both `my_control_node` and `my_ctrl_node` can be used in the DSL.

## Troubleshoot and debug your trees

Sometimes you may run into issues with your tree, and it's generally difficult to debug a recursive structure, but here are a few ways to make it a bit easier to debug and troubleshoot.

### Detecting cycles

You can check if your tree has cycles by executing the following:

```ruby
my_tree.cycle?
# => false
```

### Checking nodes are all unique objects

Sometimes you might accidentally chain the same node to a parent node. When this happens, the node will have multiple parents. Since this might be a desired situation in some cases, nodes are not cloned automatically by default.

You can check for repeated nodes using the following methods:

```ruby
my_tree.uniq_nodes?
# => true
```

Or obtain the actual repeated nodes:

```ruby
my_tree.repeated_nodes
# => <Set: { ... repeated nodes ... }>
```

**Note:** Object equality is tested using `Set#include?`.

### Visualize a tree

Printing the tree is not only useful for verifying it has the desired structure, but also for detecting various issues.

```ruby
200.times { my_tree.tick! }

my_tree.print
```

The above code generates the following output:

<p align="center">
  <img src="https://github.com/FeloVilches/ruby-behavior-tree/blob/main/assets/printed_tree.jpg?raw=true" width="400"/>
</p>

In the example above, you can see that the bottom nodes haven't been ticked at all. Node starvation might occur for various reasons, such as having a `force_failure` node as one of the children of a `sequence` (the nodes after the `force_failure` would all be prevented from executing).

Printing can also be useful in detecting bugs in your custom nodes.

## Miscellaneous

### Generate random trees

Mostly created for debugging and testing various trees in development mode, you can generate random trees by executing the following code:

```ruby
random_tree = BehaviorTree::Builder.build_random_tree

100.times { random_tree.tick! }
random_tree.print
# Output:
# ∅
# └─selector running (100 ticks)
#       ├─forcefailure failure (76 ticks)
#       │     └─repeater success (76 ticks)
#       │           └─retry success (95 ticks)
#       │                 └─task success (114 ticks)
#       ├─inverter running (47 ticks)
#
# (the rest is omitted)
```

Or make it smaller/larger by tweaking the optional argument `recursion_amount`:

```ruby
random_tree = BehaviorTree::Builder.build_random_tree(recursion_amount: 9)
```

Keep in mind this is only for development purposes, and the generated trees don't make sense at all. Also, only vanilla default nodes are used. Conditional nodes fail or succeed randomly, and task nodes generate random return values as well.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/FeloVilches/ruby-behavior-tree. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/FeloVilches/ruby-behavior-tree/blob/main/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Behavior Tree project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/FeloVilches/ruby-behavior-tree/blob/main/CODE_OF_CONDUCT.md).
