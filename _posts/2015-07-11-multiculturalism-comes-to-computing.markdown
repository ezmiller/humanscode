---
layout: post
title:  "Multiculturalism Comes to Computing at PolyConf"
author: Ethan Miller
date:   2015-07-11
category: programming
tags: 
- polyglot 
- microservices 
- polyconf 
- wittegenstein
---

Recently, I attended [PolyConf](http://polyconf.com) ([#PolyConf](https://twitter.com/hashtag/PolyConf)) in Poznan, Poland. The conference was organized around the idea of polyglot programming, a philosophical approach to programming that stresses the value of coding in multiple languages. Set against a tendency that often finds developers lamenting the chaos of programming languages as if they'd entered the Tower of Babel, the polyglot programmer instead embraces this diversity. Relishing the conceptual range that they express, she takes an anthropological stance. Seeking breadth in addition to depth, she learns to operate in these languages and their respective communities, but always also seeks to think beyond their individual limts, weighing their strengths and weaknesses.

Appropriately, then, PolyConf was a conference at which the ghosts of philosophers that have emphasized the concept of linguistic relativity were present. The impulse was not so much toward the likes of Plato or the Indian grammarian Panini,[^1] who emphasized logical and formal purity in their search for the unchanging and eternal. Rather, the impulse at PolyConf was thoroughly Wittgensteinian. Indeed, Wittgenstein showed up in at least three talks and served as an authoritative voice for the idea that limiting yourself to one language limits your conceptual range:

<blockquote class="twitter-tweet" lang="en"><p lang="de" dir="ltr">Wittgenstein at <a href="https://twitter.com/hashtag/PolyConf?src=hash">#PolyConf</a>. <a href="http://t.co/mAOP8oFgvJ">pic.twitter.com/mAOP8oFgvJ</a></p>&mdash; Ethan Miller (@ezmiller) <a href="https://twitter.com/ezmiller/status/616974145973288965">July 3, 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

Interestingly, Wittgenstein's ideas were also marshalled on a deeper level at the conference on behalf of the notion that programming languages can effectively be conceived of as pragmatic linguistic games. In other words, the idea that far from being more or less syntactically conformed to eternal or unchanging forms of computational thought, what languages do is set up the terms upon which we communicate and get things done in a given application space. 

As Charles Pletcher ([@brophocles](http://twitter.com/brophocles)) suggested in [his excellent talk](http://t.co/dnQRC9XC18) at the conference, it is quite possible to conceive of an applications themselves as interlocking language games. In his talk, Charles quoted directly from Wittgenstein's introductory description of a language game, which, remarkably, if one thinks of a computer instead of a human sounds lot like a description of a computational process. Here is the quote in which Wittgenstein is introducing the idea of a language game by describing the activity of two builders:

> [Builder] A is building with building stones: there are blocks, pillars, slabs, and beams. [Builder] B has to
pass him the stones and to do so in the order in which A needs them. For this purpose
they make use of a language consisting of the words “block”, “pillar”, “slab”, “beam”. A
calls them out; B brings the stone which he has learnt to bring at such-and-such a call.[^2]

If A and B are different modules within an application ecosystem, the words block, pillar, and slab are analogous to pieces of data being passed around the system. But in this scenario, as Charles pointed, out "A’s internal processes that prompts him or her to call out, 'block,' or 'slab,' have little bearing on B’s internal processes that help him match A’s command with the requested piece of material...A does not exist for B, but rather they both exist to produce some output together."[^3] What this means is that A and B can be modules written in different languages, which are each perhaps themselves optimally capably of doing whatever it is they do, and as long as they can communicate about blocks, pillars, and slabs effectively, the process carries on.

This approach is known generally as polyglot microservices architecture, and I find it both interesting and ambitious. In a sense, it's hard to say which is the more ambitious aim: the so-called isomorphic approach to software architecture in which one hopes or expects to be able to build one solid monolithic application in a language that is equally well-suited to solving all problems; or, this polyglot approach in which what is proposed is the capacity to set up what is essentially a smoothly functioning game of language games &mdash; one in which applications modules executing in different languages, each with their own expectations and assumptions, can coexist and co-operate harmoniously in the same environment.

As with many things, the merits of these different approaches differs by the context and the use-case. Nonetheless, I think the polyglot microservices approach holds great appeal. Programming languages are formal systems created by humans, which tightly bind syntax, symbolism, and meaning around finite sets of rules. As such, they have the potential to be very stable. Yet, because they are created by humans, they are also flawed and partial. The strength of an application built with the polyglot approach is that it has been designed from the outset with the idea that differences exist and must be mediated. Such a system, it seems to me, will be more robust than one built on the presumption that each process should operate based with the same set of expectations and assumptions. What's more the unique powers of each language can, in such a system, be leveraged to make the whole more expressive and powerful. 

Indeed, what we have here is the Tower of Babel reconceived as an organized computational multitude; it's the notion of cosmopolitan multiculturalism brought to the domain of computing.

[^1]: On the origins of modern programming languages in Pannini's search for eternal and immutable lingusitic structures, see Vikram Chandra, <em>Geek Sublime: Writing Fiction, Coding Software</em> (London: Faber & Faber, 2013), Ch. 3.
[^2]: Ludwig Wittgenstein, <em>Philosophical Investigations</em>, trans. G. E. M. Anscombe, P. M. S. Hacker, and Joachim Schulte (Malden, MA: Blackwell Publishers, 2009, c1953) §2.
[^3]: Charles Pletcher, ["Polyglot Micro-Services with a Dash of Wittgenstein"](https%3A%2F%2Fdl.dropboxusercontent.com%2Fu%2F24477149%2FCharles%20Pletcher%20-%20Polyglot%20Micro-Services%20with%20a%20Dash%20of%20Wittgenstein.pdf)Accessed on July 10th, 2015.
