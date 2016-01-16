---
layout: post
title:  "React (is) philosophy"
author: Ethan Miller
date:   2015-06-17 
categories: react
---

Once upon a time front-end web development was no fun at all. One had to deal with myriad browser idiosyncracies and it was a great challenge if not impossible to write easily maintainable code that didn't repeat itself, that separated concerns, and expressed the logic of the interface clearly. Nowadays, however, things have come a long long way. There are a range of frameworks -- most of them conforming in one way or another to the MVC pattern -- that allow one to take a more orthogonal approach to web development. 

Among these, I've been working with a new javascript library known as [React](https://facebook.github.io/react/) that changes the game considerably. Developed by Facebook as an open source initiative, React is exciting because it makes it possible to start thinking about front-end web development at a more abstract, one might even even philosophical, level.

The first description of React that one usually encounters -- the one that appears on facebook's page for the library -- describes it as the V in an MVC pattern. This is the case because React is primarily used to encapsulate logic about the user interface or "view". Yet to describe React as the V in MVC doesn't get at the ideas that React implements which make it unique and indeed potentially revolutionary.

Essentially, React is an attempt to simplyify the problem of managing (changing) state in a web application. "State," for those readers that may not understand the term, simply refers to those properties of a thing -- in this case a program -- that change over time. The problem of keeping track of state over time is one of the hardest things for the human mind to do; as such it is often a source of bugs. This is where React -- and indeed other modern frameworkks -- have stepped in. Their goal being basically to free us from the problem of needing to manage state directly. 

This point was well expressed by Tom Occhino, one of the members of the Facebook team involved in React's development, when he compared React to jQuery: 

<blockquote>[The innovation of jQuery was that it] smoothed mutations across browsers. React makes it so you do not have to think of mutations at all. You just describe declaratively what it looks like at any [given] point in time.</blockquote> 

The key concept here is that in using React one can describe the UI "declaratively" What Occhino is indiating here is that React veers in the direction of a programming paradigm -- related to functional programming -- in which one is freed to think about logic of compuation in a program instead of needing to manage "imperatively" the order of changes and transformations that characterise the "control flow"of a program from one state to the next. So, to sum this up: With React we are freed to describe the logical structure of the UI in each state rather than needing to manage "imperatively" how the UI should change over time. 



<code>
var someGlobal = rand(2);
function fn(num) {
	
}

// impure
var minimum = 21;

var checkAge = function(age) {
  return age >= minimum;
};



// pure
var checkAge = function(age) {
  var minimum = 21;
  return age >= minimum;
};		

"Many believe the biggest win when working with pure functions is referential transparency. A spot of code is referentially transparent when it can be substituted for its evaluated value without changing the behavior of the program. Since pure functions always return the same output given the same input, we can rely on them to always return the same results and thus preserve referential transparency." (https://github.com/DrBoolean/mostly-adequate-guide/blob/master/ch3.md)



