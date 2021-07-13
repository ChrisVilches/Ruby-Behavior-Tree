# Memo

## Event-driven trees

Implementing conditionals. This can be useful for creating event-driven behavior trees.

https://docs.unrealengine.com/4.26/en-US/InteractiveExperiences/ArtificialIntelligence/BehaviorTrees/BehaviorTreesOverview/

> In the section of a Behavior Tree above, the Decorators Close Enough and Blackboard can prevent the execution of the Sequence node's children. Another advantage of conditional Decorators is that it is easy to make those Decorators act as observers (waiting for events) at critical nodes in the tree. This feature is critical to gaining full advantage from the event-driven nature of the trees.

## Task-only decorators

There might be the need to implement decorators that can only have a task child (as opposed to having a selector/sequence node as a child, etc). How can I implement this? I can probably add just a simple check to make sure the decorator has a task node, but I'd need to think how to make it elegant.

## Rename TaskBase to Task

~~Consider renaming it, because this class will be used by users (programmers), and the name is a bit long.~~

## TODO

1. ~~Mechanism to add new keywords to the DSL. Maybe make it the same way as it is now, by defining a mapping hash, but make it configurable (dynamic). The user can add keywords, and assign a class name.~~
2. ~~Way to create new control nodes, and make it easy to pass strategies. So far, strategies are defined in modules, but this makes them hardcoded. So the idea is that it's easier to do. The idea is that selector/sequence logics can be mixed with different strategies. So if the user wants to create a new type of selector, they can start from the normal selector, and add a strategy. This means that the two components of a control node is (1) how it selects/sequences, and (2) children iteration.~~

## Implement an `init` and `process` lifecycle for leaf nodes

This seems nice, and not very hard to implement.

https://www.gamasutra.com/blogs/ChrisSimpson/20140717/221339/Behavior_trees_for_AI_How_they_work.php

> init - Called the first time a node is visited by its parent during its parents execution. For example a sequence will call this when its the node’s turn to be processed. It will not be called again until the next time the parent node is fired after the parent has finished processing and returned a result to its parent. This function is used to initialise the node and start the action the node represents. Using our walk example, it will retrieve the parameters and perhaps initiate the pathfinding job.
>
> process - This is called every tick of the behaviour tree while the node is processing. If this function returns Success or Failure, then its processing will end and the result passed to its parent. If it returns Running it will be reprocessed next tick, and again and again until it returns a Success or Failure. In the Walk example, it will return Running until the pathfinding either succeeds or fails.

## Optimization

(Regarding traversing entire tree every frame)

> This isn’t a very efficient way to do things, especially when the behaviour tree gets deeper as its developed and expanded during development. I’d say its a must that any behaviour tree you implement should store any currently processing nodes so they can be ticked directly within the behaviour tree engine rather than per tick traversal of the entire tree.

How can this be incorporated seamlessly without breaking too much into the existing code?
