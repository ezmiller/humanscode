---
layout: post
title: Columns For Tablecloth
author: Ethan Miller
date:   2022-06-28
categories: clojure data-science
---

For a few years now, I have been working with a unique, global group
of people associated with the [SciCloj](https://scicloj.github.io/)
community, many of whom are interested in promoting the use of Clojure
for data-centric computing. As part of this effort, I recently applied
for and then received funding from [Clojurists
Together](https://www.clojuriststogether.org/open-source/) -- an
organization in the Clojure community that provides funding for open
source work on Clojure tools -- to contribute to an important new
data-processing library called
[tablecloth](https://github.com/scicloj/tablecloth).

## The context for the project

Before delving into the nature of the project itself, I want to
quickly explain my understanding of where this library tablecloth fits
into the emerging Clojure data stack so it's clear why I think this
project is worthwhile. Generally, speaking much of the work that I've
been doing within SciCloj has been focused on the question of
usabilty. The problem of usability has emerged only because in the
last years a number of very talented individuals have created a set of
powerful new tools that provide the bedrock for highly performant
data-processing in Clojure.

One of the tools that has become particularly prominent is the
so-called "tech" stack developed by [Chris
Nurenberger](https://github.com/cnuernber). This stack consists of a
low-level library called
[dtype-next](https://github.com/cnuernber/dtype-next), which provides
a method for handling typed arrays or buffers (see a workshop I gave
on this library
[here](https://www.youtube.com/watch?v=5u3_k_D5KSI&t=565s&ab_channel=LondonClojurians)),
and [tech.ml.dataset](https://github.com/techascent/tech.ml.dataset)
that provides a column-based tabular `dataset` much like the
"dataframes" one finds in R or Python's Pandas library.

Using just tech.ml.dataset, one can already perform analyses over
large amounts of data. Indeed, in many cases, thanks to Chris
Nurenberger's amazing work, this stack can outperform equivalent tools
in Python, R, and even Julia.[^1] However, although very usable in its
own right, tech.ml.dataset is somewhat low level and its API is not
always consistent. For this reason, many people start out with the
library to which I will be contributing:
[tablecloth](https://github.com/scicloj/tablecloth).

Tablecloth is essentially a wrapper on top of tech.ml.dataset.
Authored by Tomasz Sulej
([@generateme_blog](https://twitter.com/generateme_blog)), who has
created many other useful libraries and has a knack for creating
beautiful tools, it provides a consistent API for interacting with
`datasets` that is inspired by the user-friendly syntax of R's
tidyverse libraries among others.

## My project: columns for tablecloth

What I will work on during this project, then is adding a new
dimension to tablecloth's API. Currently, the focus of tablecloth's
API is the `dataset`. This, of course, makes perfect sense since in
many cases when working with data, especially when manipulating data
as a preparation for feature engineering, you are working primarily at
the level of the whole `dataset`.

Sometimes, however, you may want to perform operations not across a
whole dataset (or set of columns), but on a single column. And that's
where my project comes in. It will add add a new API for the `column`
to tablecloth. In other words, once we've added this API we should, at
the very least, be able to do something like:

```clojure
(def a (column [20 30 40 50]))
(def b (column (range 4)))
(- a b)
;; => [20 29 38 47]
```

The goal is to make the `column`, like the `dataset`, a first-class
primitive within the tech stack. Like R's vectors and Numpy's `array`,
the hope is that when people are working with tablecloth, users can
reach for the `column` when they need to do some focused processing on
a 1d (or perhaps 2d set of items).

## A big open question: n-dimensionality

When I originally conceived of this project, I thought what we might
be doing is bringing full-fledged support for n-dimensional arrays
into tablecloth. Indeed, I orgiinally conceived of the project as an
adjunct library called `tablecloth.array`. My thought was that this
distinct library might eschew reliance on `tech.ml.dataset` -- which
has some startup costs -- and simply rely on the lower-level library
dtype-next, which has the key tools for efficient array processing and
is in fact the basis for tech.ml.datset's columns.

However, for a number of reasons this is not practical. First, there
is already a solid tool for array processing in the Clojure world: the
[neanderathal](https://github.com/uncomplicate/neanderthal) library by
Dragan Djuric ([@draganrocks](https://twitter.com/draganrocks)).
Second, dtype-next is so low-level that some of the things that one
might need, such as automatic scanning of the items in an array to
determine their datatype, are not present by default. Right now,
anyway, those features only exist within tech.ml.dataset's `Column`
type. As such, what we decided to do is build directly on the
tech.ml.dataset's `Column` as we get so much for free.

One consequence of this approach is that we cannot easily add
n-dimensional support. The `column` in tech.ml.dataset, as the name
might suggest, is not designed for multi-dimensionality. It is built
on a single dtype-next buffer. There are possible approaches for
layering on support for n-dimensionality, for example, as Chris
Nurenberger put it:

> [A]s far as if a column could be N-D, you can take a linear random access
> array and make it ND via an addressing operator...[^2]

This solution sounds like a promising approach, but involves
sufficient complexity that I think it will remain out of scope for
this project. Another idea that was batted around briefly was whether
we could support just two dimensions if we just allowed tablecloth's
column API to pass around a dataset internally as a kind of
representation of a two dimensional matrix.

However, I think ghosting behind these technical implementation
questions is a more general question of what people need. The impetus
for this project was about usability. We already have powerful tools
such as neanderthal and core.matrix that handle matrix operations. We
wanted to build support for those kind of operations within the
syntactical vernacular of tablecloth, which so many people have found
pleasant to use. It's about making it so that users don't need to
change tools, and with it their whole mental model for working with the
tool they are using.

Yet I think it is fair to say we still don't know what people really
need in this space. In that respect, I think of this project as an
experiment. It is better that we do not go whole hog and try to get
n-dimensions right away. What we'll do first is try to build a
sensible column API for tablecloth and then see how (and if) it is
used. Perhaps there will be a need for more dimensions; perhaps not. 

## What I've done so far

Now for what work has been done so far. Much of what I have been doing
so far has been research. I have reviewed some key tutorials for
Python Numpy
([here](https://numpy.org/doc/stable/user/quickstart.html)) and R's
vectors ([here](https://adv-r.hadley.nz/vectors-chap.html)) in an
attempt to study the other dominant APIs. I've also had a planning
session with the author of tablecloth, Tomasz Sulej, to think about
dimensionailty issue detailed above as well as the kinds of
functionality we want to target during this project.

Here roughly, are the main areas of work that we think now will emerge
more or less in order:

1. Establish the core "primitive" of the `column`, i.e. the entity
   that users will be able to create and manipulate;
2. Build out any necessary API for indexing, slicing and interating;
3. Lift various relevant operations and linear algebra functions that
   are in dtype-next into tablecloth, in particular dtype-next's
   "functional" namespace (i.e.
   [`tech.v3.datatype.functional`](https://github.com/cnuernber/dtype-next/blob/master/src/tech/v3/datatype/functional.clj)); 
4. finally, consider importing ideas from R's "factors" and lapply iterators.

So far the hard coding work that has been done relates to the first
item above: establishing the `column` primitive. This
[PR](https://github.com/scicloj/tablecloth/pull/71) does two things:

1. It establishes a new api domain: `tablecloth.column.api`. Rather
   than mixing column support into tablecloth's main api
   (`tablecloth.api`), Tomasz suggested we keep it distinct. This
   should help clarify when we are dealing with a column and when we
   are dealing with a dataset. It also means that we don't end up with
   naming collisions (e.g. for example there's already a
   `tablecloth.api/column` function).
2. It adds a basic set of core functions that establish the `column`
   primitive. These are:
   - `column` - creates a column
   - `column?` - identifies a column
   - `typeof`/`typeof?` - identify the datatypes of the column's elements
   - `ones` / `zeros` - create columns filled with ones or zeros
   
There's not a lot to say about these functions that is probably not
rather obvious. One thing to note is that the inspiration is here
being taken from both the R and Python worlds. R uses the name
`typeof` for its typed "atomic" vectors, and Python's Numpy uses the
functions `ones` and `zeros`. This practice of drawing on (hopefully
the best) of the existing libraries in other languages is something
that I intend to continue and do even more deeply, and which I believe
is key to the Tomasz's strategy in building tablecloth to begin with.

## Next steps

Having established the `tablecloth.column.api` namespace, the next
major step I think will be to build out from this simple core of
functions making it possible to do more with columns. This means
considering either basic operations or indexing, slicing, and
iterating over columns. I have a sense that indexing, slicing, and
iterating will take precedence.

I also want to try to quickly conduct a rough survey of the operations
that we might include, a kind of working spec or planning document.
This way I can look at the full set of operations in one place, and
also understand what we may take from the various existing APIs from
which we want to learn. In other words, what can concepts/functions
may we want to darw on from Numpy, from R, from Julia, and so on.

[^1]: Chris Nurenberger, "High Performance Data with Clojure."
    *YouTube*, 9 June 2021, https://youtu.be/5mUGu4RlwKE.
[^2]: Chris Nurenberger. Message posted to #data-science channel,
    topic: "matrix muliplication in dtype-next". *Clojurians Zulip*, 20
    September 2021.
  
