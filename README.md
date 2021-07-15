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

### Use object oriented programming

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
sequence = BehaviorTree::Selector.new
sequence << another_tree
```

When chaining trees, the root node of the tree to be chained will be removed, and its single child will be chained instead. This is because the root node of a tree doesn't add any value to the tree, other than wrapping its single child.

## Basics

### Ticking the tree

Explain what ticking is

### Node status

### Types of nodes

#### Task nodes

Explain what it is

#### Control nodes

Explain what it is
Explain the two types

#### Decorators

Explain what it is

#### Condition nodes

Explain what it is

## Create custom nodes

### Custom task

### Custom control node

TODO: Talk about traversal strategies and stuff

### Custom decorator

### Node API

#### Callbacks and hooks

tick!

halt!

on_status_change `on_status_change(prev, curr)`

on_tick

ensure_after_tick

on_started_running

on_finished_running

should_tick?

### Storage

#### Global context

what can it be used for

#### Per-node storage

Only used in conditional nodes.

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

Note that object equality is tested using `Set#include?`.

### Visualize a tree

Printing the tree data might be useful for detecting various issues.

```
200.times { my_tree.tick! }

my_tree.print
```

The above code generates the following output:

<p align="center">
  <img src="https://github.com/FeloVilches/ruby-behavior-tree/blob/main/assets/printed_tree.jpg?raw=true" />
</p>

In the example above, you can see that the bottom nodes haven't been ticked at all. Node starvation might occur for various reasons, such as having a `force_failure` node as one of the children of a `sequence` (the nodes following the `force_failure` would all be prevented from executing).

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
