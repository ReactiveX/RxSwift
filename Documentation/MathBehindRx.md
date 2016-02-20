Math Behind Rx
==============

## Duality between Observer and Iterator / Enumerator / Generator / Sequences

There is a duality between the observer and generator patterns. This is what enables us to transition from the async callback world to synchronous world of sequence transformations.

In short, the enumerator and observer patterns both describe sequences. It's fairly obvious why the  enumerator defines a sequence, but the observer is slightly more complicated.

There is, however, a pretty simple example that doesn't require a lot of mathematical knowledge. Assume that you are observing the position of your mouse cursor on screen at given time periods. Over time, these mouse positions form a sequence. This is, in essence, an observer sequence.

There are two basic ways elements of a sequence can be accessed:

* Push interface - Observer (observed elements over time make a sequence)
* Pull interface - Iterator / Enumerator / Generator

You can also see a more formal explanation in this video:

* [Expert to Expert: Brian Beckman and Erik Meijer - Inside the .NET Reactive Framework (Rx) (video)](https://www.youtube.com/watch?v=looJcaeboBY)
* [Reactive Programming Overview (Jafar Husain from Netflix)](https://www.youtube.com/watch?v=dwP1TNXE6fc)
