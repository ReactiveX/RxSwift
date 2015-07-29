Math Behind Rx
==============

## Duality between Observer and Iterator / Enumerator / Generator / Sequences

There is a duality between observer and generator pattern. That's what enables transition from async callback world to synchronous world of sequence transformations.

In short, enumerator and observer pattern both describe sequences. It's pretty obvious why does enumerator defined sequence, but what about observer.

There is also a pretty simple explanation that doesn't include a lot of math. Assume that you are observing mouse movements. Every received mouse movement is an element of a sequence of mouse movements over time.

In short, there are two basic ways elements of a sequence can be accessed.

* Push interface - Observer (observed elements over time make a sequence)
* Pull interface - Iterator / Enumerator / Generator

To learn more about this, these videos should help

You can also see a more formal explanation explained in a fun way in this video:

[Expert to Expert: Brian Beckman and Erik Meijer - Inside the .NET Reactive Framework (Rx) (video)](https://www.youtube.com/watch?v=looJcaeboBY)
