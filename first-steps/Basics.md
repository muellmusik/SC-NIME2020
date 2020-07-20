
# Table of Contents

    1.  [Overview of SC elements](#org3d079f8)
    2.  [Comments](#org6632530)
    3.  [Variables and abstraction](#org12057c3)
    4.  [Some theory on Variables](#orga078c8d)
        1.  [Global vs. local Variables](#org9609375)
    5.  [Functions](#org7ffa890)
1.  [Reading list](#org91024ac)
    1.  [Links to online resources](#org99ff975)



<a id="org3d079f8"></a>

## Overview of SC elements

Below you can see some of the main elements that we will encounter while working in SC.

    // This is a comment,
    // anything that follows the two slashes,
    // in the beginning will be not taken,
    // into account.
    
    var foo; //this is a variable, predefined using keyword: var.
    
    arg bar; //this is an argument, predefined using keyword: arg.
    
    SinOsc, Pan2 //This is a class, denoted always first letter with capital letter.
    
    (
    a = {...}; //a function, wrapped inside a region. Here we add anything that will be executed as a function.
    a.postln;
    )


<a id="org6632530"></a>

## Comments

A comment is literary anything you want to add as a comment besides the real code inside your program, this may be some note to your self or to others that might need through your code or an explanation next to a line of code, see the previous examples above, anything that is following the two // format will be ignored when executing code.


<a id="org12057c3"></a>

## Variables and abstraction

In the last tutorial we covered how to run some first lines in the SC
IDE, and learned how to understand the ecosystem of the language. The
basics, at the left you type the commands, at the right by default, you
are receiving feedback in real time about what your commands doing, and
potential errors, for example syntax and other problems encountered
during the execution of the large or small snippets of code. We also
covered how to execute one line or larger regions and how to add
comments in our code, something very important while working with
scripting languages.

Unlike other computer languages SC is real time meaning that you don&rsquo;t
have to &rsquo;compile&rsquo; anything and wait for potential errors while this
procedure. This makes sense for live situations especially when
improvising algorithms on the fly as the strategy for the musical
performance. For now we will focus
on the basics of creating small programs that contain basic abstraction
of &ldquo;things&rdquo; named Variables.

Variables are one of the most powerful way to describe something inside
a program, enabling the interaction of reusable bits of
code inside a program. For this reason we will hear this word quite a
lot from now on, so make sure you have an idea what a variable is and
how it can be used after this tutorial, run your own and experiment with
their manipulation and see the differences.

So a variable basically is a name we give to things inside regions of
code:

    (
      var apple = "I am a red apple";
      apple.postln;
      )

In this code above the apple is the name of the variable in which we may store
anything, can you guess why this is important&#x2026; In
this way we can add things to names and make many manipulations on them
without typing again again all the time, which would be
counterproductive assuming programs are large text blocks and everything
needs to be written in a precise manner.

So for now you can imagine a variable being a name for something we are
going to use later in our system. It&rsquo;s a bin a storage placeholder, it&rsquo;s
nothing until you assign something to it, otherwise it&rsquo;s \`\`\`\`nil\`\`\`\`, a
word you will get used to it eventually when programming.

Try the following code below:

    (
      var apple;
      apple.postln
      )

And a little more experimentation with variables to understand their cuteness.

    (
    var apple = "big apple";
    var appleColor = "red, and juicy";
    ("I am a " ++ apple ++ " " ++ appleColor)
    )

You probably noticed some minor additional bits in the last sentence, this is because in programming things are not always exactly how they suppose to be so many times you will have to make some workarounds, especially when is about formatting like strings for example. Now go on and make your additions to the current code and try to make it more complex and fun by adding more variables.


<a id="orga078c8d"></a>

## Some theory on Variables

Variables as assigned using the keyword **var**, after this word you may assign any names that make sense in your program. Variables are stored on the temporary memory of SC.

At this stage you have a good idea what is a variable and how it can be
used in a program to make things easier. One thing that you probably
haven&rsquo;t realized is that you interacting with something called objects;
Objects in object oriented programming is all we using to make our
programs. Thus, an object can be a number, remember last tutorial making
some mathematical operations on two numbers and summing or multiplying
them. A number is an object we can perform multiple operations on it,
but not all, why? Because different objects have diverse functionality.
For exaple, we can do this on a string:

    "hello" ++ "world"

That is, concatenate two strings using two sum signs to merge them. See
the next example, and maybe try to fix it, can you imagine what&rsquo;s wrong
with it?

    (
    var a = 1;
    var b = 2;
    var sum = a ++ b;
    sum
    )

Look into the post window and spot the cause of the error.
The issue here lies to the fact that all object have different
attributes and thus different outcome and behavior when manipulating
them, whether this is inside a string or a mathematical operation.

Try to write some region that does an operation to numbers and
concatenates some words wrapped in strings and assigned in variables.
You may also declare a variable that uses another variable declared
**first**.


<a id="org9609375"></a>

### Global vs. local Variables

A problem that arises often with variables is that, variables can exist in a region that you execute inside the matching parenthesis. This sometimes is not convenient, for example you have something like below:

    (
    var lorem = "lorem ipsum dolor sit amet",
    ipsum = "consectetur adipisicing elit";
    lorem ++ " " ++ ipsum
     )

What if &ldquo;ipsum&rdquo; variable can&rsquo;t co exist with the rest of the
declared variables inside the same region.


<a id="org7ffa890"></a>

## Functions

Functions are the building blocks of our programs, so if a program is a
house then functions are the bricks. Functions in SC are denoted by
curly brackets:

    { } //this is a function

If you copy and evaluate it in SC it will return <span class="underline">-> a Function</span>.
Functions have unique names and by calling them anywhere inside our
program we can reuse them and pass their output as input to another
function. See this example:

    (
    y = {
    	a = 10;//integer
    	b = 20;
    	a / b;
    }
    );
    /* Function y will be used in the next function x */
    (
    x = {
    	arg foo;
    	var bar = 100;
    	y.value / foo * bar; //see y func
    };
    );
    
    x.value(0.5);

Template for functions that we will be using as follows:

    (
    a = {
    	arg freq = 0.5,
    	amp = 0.35;
    	//operations
    	freq / amp;
    }
    )

We need to add &ldquo;.value&rdquo; at the end of the function, or add a callback like this example below in order to give us the result.

Run this to learn the result of the <span class="underline">a</span> function:

    a.value

It will return this:

    -> 1.4285714285714


<a id="org91024ac"></a>

# Reading list

SuperCollider Handbook pp.6-18 <span class="underline">Messages and Arguments</span>.

SuperCollider Handbook pp.6-18 <span class="underline">Variables</span>.

SuperCollider Handbook pp.128 <span class="underline">Objects and Classes</span>.


<a id="org99ff975"></a>

## Links to online resources

Object Oriented Programming for Beginners, this is not to be understood thoroughly at this stage but it is a useful resource for understanding OOP in general terms, found at this link:
<https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Objects/Object-oriented_JS>

