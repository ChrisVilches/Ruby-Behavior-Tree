# Ruby Behavior Tree

![](https://api.travis-ci.com/FeloVilches/Ruby-Behavior-Tree.svg?branch=main)

## Try on console

Open `irb` console.

```bash
irb -r ./main.rb
```

Test it with this simple code:

```ruby
# Create a selector node.
selector = BehaviorTree::Selector.new

# Add three NOP operations (tasks that don't do anything).
3.times { selector << BehaviorTree::Nop.new }
```

## Test

Install necessary gems:

```bash
bundle install
```

```bash
bundle exec rspec
```

Or run tests automatically with each file change:

```bash
bundle exec guard
```

However this needs `unbuffer` to be installed, so install with (on Linux):

```bash
sudo apt-get install expect
```
