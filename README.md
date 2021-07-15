# Behavior Tree

[![Travis CI](https://api.travis-ci.com/FeloVilches/Ruby-Behavior-Tree.svg?branch=main)](https://travis-ci.org/github/FeloVilches/Ruby-Behavior-Tree) [![Gem Version](https://badge.fury.io/rb/behavior_tree.svg)](https://rubygems.org/gems/behavior_tree)

A robust and customizable Ruby gem for creating Behavior Trees.

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

### Create a tree using the DSL

Create a tree using the DSL:

TODO: Create an example that does something lol.
```
BehaviorTree::Builder.build do
  sequence do
    task1
    custom_condition do
      task2
    end
    selector do

    end
  end
end
```

Custom node classes can be added to the DSL programmatically, and trees created without the DSL (see section below) can also be chained to a branch as a subtree.

### Use object oriented programming

If the tree or part of it cannot be built with the DSL, then you can build it programmatically like so:

```ruby
# Initialize an empty sequence.
sequence = BehaviorTree::Sequence.new

# Task with inline logic.
task1 = BehaviorTree::Task.new { puts "I'm a task" }

# Task with logic defined inside the class definition (custom).
task2 = MyCustomTask.new

# Add as children.
sequence << task1
sequence << task2

# Finally build the tree.
my_tree = BehaviorTree::Tree.new sequence

my_tree.tick!
# Output:
# I'm a task

my_tree.print
# ∅
# └─sequence running (1 ticks)
#       ├─task running (1 ticks)
#       └─task success (0 ticks)
```

### Chain trees together

You can join trees that were created with any of the above methods (DSL or simple Ruby object programming) by doing something like this:

**Example #1: Chain a tree inside the DSL**

```ruby
# Create selector without children.
selector = BehaviorTree::Selector.new

# Create a tree with the selector as child.
another_tree = BehaviorTree::Tree.new(selector)

# Create a tree using the DSL, but chain the previously created tree.
BehaviorTree::Builder.build do
  inverter do
    chain(another_tree)
  end
end
```

**Example #2: Chain a tree by adding it to a node's children**

Chain the `another_tree` created in the previous example to the children array of a `sequence` node.

```ruby
sequence = BehaviorTree::Sequence.new
sequence << another_tree
```

When chaining trees, the root node of the tree to be chained will be removed, and its single child will be chained instead. This is because the root node of a tree doesn't add any value to the tree, other than wrapping its single child.

## Basics

What is a behavior tree? According to the [Wikipedia](https://en.wikipedia.org/wiki/Behavior_tree_(artificial_intelligence,_robotics_and_control)):

> A behavior tree is a mathematical model of plan execution used in computer science, robotics, control systems and video games. They describe switchings between a finite set of tasks in a modular fashion. Their strength comes from their ability to create very complex tasks composed of simple tasks, without worrying how the simple tasks are implemented.

In simple words, it's a modular way to describe your control-flow, in a very flexible and scalable way. It avoids the common pitfalls of usual control-flow (i.e. `if-else`), such as spaghetti code, by structuring the logic as a tree, with branches (conditionals, sequence of tasks, etc) and leaf nodes (tasks to be executed).

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

Just like you would be able to access local variables inside an `if-else` block, a behavior tree has a data structure called `context` which it can operate on. If this didn't exist, there would be no data to manipulate, and take decisions on. In other implementations, it's called *blackboard*, a concept which refers to a global memory.

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

The preferred way to store node-scoped data is to use vanilla Ruby `@instance_variables`, but this is only possible if you are creating a custom class.

Note: `node_instance` is **not** a `Hash` object, but instead a Node object. This is implemented by overloading the `[]=` and `[]` operators.

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

See the section about DSL to learn how to register your custom nodes so they can be used more easily.

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

There are two types of control nodes, and custom ones can be easily created (see examples in the section about custom control nodes).

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

When a control node is ticked, by default it traverses children and ticks them using this logic:

1. If at least one node is `running`, then begin from that one, in order.
2. If no node is `running`, then traverse all nodes starting from the first one, in order.

Note: When a node gets "halted", it simply means it's resetted, and its status set to `success`. Some nodes have additional logic. Please refer to `halt!` section.

#### Decorators

A decorator can have only one child, and adds additional functionalities.

By default the decorator nodes present in this library are:

| Name | Class | DSL | Description |
| --- | --- | --- | --- |
| Condition | `BehaviorTree::Decorators::Condition` | `condition` or `cond` | Ticks its child only if the condition succeeds. If not, returns `failure` (and has no effect whatsoever on the child). If the condition succeeds, it ticks the child and returns its status. |
| Force Failure | `BehaviorTree::Decorators::ForceFailure` | `force_failure` | Ticks the child, and always returns `failure` regardless of what the child returned. |
| Force Success | `BehaviorTree::Decorators::ForceSuccess` | `force_success`| Ticks the child, and always returns `success` regardless of what the child returned. |
| Inverter | `BehaviorTree::Decorators::Inverter` | `inverter` or `inv` | Returns `running` if the child returns `running`, and returns the opposite (inverted status) when the child returns `failure` or `success`. |
| Repeater | `BehaviorTree::Decorators::Repeater` | `repeater` or  `rep` | Ticks the child again N times while it's returning `success`. |
| Retry | `BehaviorTree::Decorators::Retry` | `re_try` | Ticks the child again N times while it's returning `failure`. |

## Create custom nodes

### Custom task

TODO: This section explains all types of task creation, not just custom. Refactor so that it's a general explanation on how to use tasks?

**Example #1 Empty task (i.e. does nothing)**

```ruby
task = BehaviorTree::TaskBase.new
```

**Example #2 Task with inline procedure**

```ruby
task = BehaviorTree::TaskBase.new -> { puts 'Hello world' }

task.tick!
# Output:
# Hello world
```

**Example #3 Task that returns status based on the context**

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
TODO: Remove Node API from here, maybe
    its more like a general explanation of nodes
    not about creating nodes specifically
**Example #4: Same as #3, but using lambdas instead**

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

**Example #2: Overriding the control-flow logic**

The example above defines a new traversal strategy, but keeps the same logic as a vanilla `Sequence`. In the following example, we continue to use the strategy defined above, but create a different control-flow logic.

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

Note that under the hood, `tick_each_children` uses the strategy defined, and also ticks the child. You don't need to send `tick!` manually to the child.

### Custom decorator

*Note: Condition nodes are a type of decorator, but they are covered separately in the next section.*

Here's an example of how to create a custom decorator. Simply inherit from `BehaviorTree::Decorators::DecoratorBase` and override the two methods present.

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

Creating a condition as a class.

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
# ∅
# └─condition failure (1 ticks)
#       └─task success (0 ticks)
```

Note: Other behavior tree implementations prefer the use of `sequence` control nodes, and placing conditional nodes as a leaves, but with the role of simply returning `failure` or `success`. Since sequences execute the next node only if the previous one succeeded, this also works as a conditional node. In this implementation, however, both patterns are available and you are free to choose which one to use.

## Node API

### Status

Every instance of node classes (i.e. descendants of `NodeBase` class) have a status object, where you can execute the following methods.

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

### tick!

As you have seen in other examples, all nodes have a `tick!` method, which as the name says, ticks the node.

The first thing it does is always setting the node to `running`.

The tick cycle has several parts, and some of them can be customized separately. Check the section about callbacks and hooks for more information.

### Callbacks and hooks

#### on_status_change(prev)

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

  def on_status_change(prev)
    # Only the previous status is passed as argument.
    # The current status can be obtained this way.
    curr = status

    puts "My status went from #{prev.to_sym} to #{curr.to_sym} (tick_count = #{tick_count})"
  end
end

task = RandomStatusTask.new

5.times { task.tick! }

# Output:
# My status went from __success__ to running (tick_count = 1)
# Being ticked...
# My status went from __running__ to failure (tick_count = 1)
# My status went from __failure__ to running (tick_count = 2)
# Being ticked...
# My status went from __running__ to failure (tick_count = 2)
# My status went from __failure__ to running (tick_count = 3)
# Being ticked...
# My status went from __running__ to success (tick_count = 3)
# My status went from __success__ to running (tick_count = 4)
# Being ticked...
# My status went from __running__ to success (tick_count = 4)
# My status went from __success__ to running (tick_count = 5)
# Being ticked...
# My status went from __running__ to failure (tick_count = 5)
```

In the output of the example above, one thing to note is that the first line (change from `success` to `running`) happens because `tick!` **immediately and always** sets the node to `running`. This happens even before the task logic (`on_tick` method) has been executed.

The second line of the output is the `puts` of the actual task logic. The third line happens as a result of the task logic changing the status, therefore triggering a `on_status_change` call.

#### on_started_running

Similar to `on_status_change`, but only triggers when the node has been set to `running`.

#### on_finished_running

Similar to `on_status_change`, but only triggers when the node has been set to a status other than `running`.

#### on_tick

This is where custom logic for when the node is being ticked can be implemented.

What you should implement differs depending on the node type.

1. **For condition nodes:** don't override this method. Override `should_tick?` instead.
2. **For control nodes:** Override the control-flow logic. In other words, you can create a control node that's not a `sequence` nor a `selector`, but something else entirely. See the custom control node example for reference.
3. **For task nodes:** The task procedure.
4. **For (non-condition) decorator nodes:** Currently overriding is not considered supported. Override the `decorate` method instead.

#### should_tick?

The default return value for this node is `true` for all nodes, except for condition nodes, where it should be overriden.

This method must return a `boolean` value.

Note: Currently all nodes have this method, however instead of overriding it in task nodes or other types of nodes, prefer creating a condition node and use it to decorate the node you want to conditionally tick.

### Add custom nodes to the DSL

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

## Validate your tree

Sometimes you may run into issues with your tree, and it's generally difficult to debug a recursive structure, but here are a few ways to make it a bit easier to debug and troubleshoot.

### Check correct tree structure

#### Detecting cycles

You can check if your tree has cycles by executing the following:

```ruby
my_tree.cycle?
# => false
```

#### Checking nodes are all unique objects

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

Note: Object equality is tested using `Set#include?`.

### Visualize a tree

Printing the tree is not only useful for verifying it has the desired structure, but also for detecting various issues.

```
200.times { my_tree.tick! }

my_tree.print
```

The above code generates the following output:

<p align="center">
  <img src="https://github.com/FeloVilches/ruby-behavior-tree/blob/main/assets/printed_tree.jpg?raw=true" />
</p>

In the example above, you can see that the bottom nodes haven't been ticked at all. Node starvation might occur for various reasons, such as having a `force_failure` node as one of the children of a `sequence` (the nodes following the `force_failure` would all be prevented from executing).

Printing can also be useful in detecting bugs in your custom nodes.

## Miscellaneous

### Generate random trees

Mostly created for the purpose of debugging and testing various trees in development mode, you can generate random trees by executing the following code:

```ruby
random_tree = BehaviorTree::Builder.build_random_tree

100.times { random_tree.tick! }
random_tree.print

# ∅
# └─selector running (100 ticks)
#       ├─forcefailure failure (76 ticks)
#       │     └─repeater success (76 ticks)
#       │           └─retry success (95 ticks)
#       │                 └─task success (114 ticks)
#       ├─inverter running (47 ticks)
#
# etc...
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
