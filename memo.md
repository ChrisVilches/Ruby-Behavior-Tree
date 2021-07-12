# Memo

## Event-driven trees

Implementing conditionals. This can be useful for creating event-driven behavior trees.

https://docs.unrealengine.com/4.26/en-US/InteractiveExperiences/ArtificialIntelligence/BehaviorTrees/BehaviorTreesOverview/

> In the section of a Behavior Tree above, the Decorators Close Enough and Blackboard can prevent the execution of the Sequence node's children. Another advantage of conditional Decorators is that it is easy to make those Decorators act as observers (waiting for events) at critical nodes in the tree. This feature is critical to gaining full advantage from the event-driven nature of the trees.

## Task-only decorators

There might be the need to implement decorators that can only have a task child (as opposed to having a selector/sequence node as a child, etc). How can I implement this? I can probably add just a simple check to make sure the decorator has a task node, but I'd need to think how to make it elegant.

## Rename TaskBase to Task

Consider renaming it, because this class will be used by users (programmers), and the name is a bit long.
