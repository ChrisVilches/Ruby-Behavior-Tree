# Ruby Behavior Tree

## Try on console

Open `irb` console.

```bash
irb -r ./loader.rb
```

Test it with this simple code:

```ruby
# Create a selector node.
selector = BehaviorTree::Selector.new

# Add three NOP operations (tasks that don't do anything).
3.times { selector << BehaviorTree::Nop.new }
```

## Test

```bash
rspec
```
