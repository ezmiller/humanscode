---
layout: post
title:  Column Support in Tablecloth
author: Ethan Miller
date:   2022-06-26
categories: clojure data-science
---

For a few years now I have been working together with a unique group
of people associated with the [SciCloj](https://scicloj.github.io/)
community, all of whom are interested in promoting the use of Clojure
for data-centric computing. 

As part of this effort, I recently put in an application and received
funding from the [Clojurists
Together](https://www.clojuriststogether.org/open-source/) an
organization in the Clojure community that does a really practical job
funding opensource work on Clojure tools. This post is the first in
what I hope to be a series of posts sharing my though process as I
work on that project over a year's time.

## The context for My Project

During this project, I will be contributing to an important
data-processing library called `tablecloth`. Before delving into the
nature of the project itself, I want to quickly explain my
understanding of where this library fits.

Much of the work that we have been doing in the SciCloj community has
revolved around improving the usability of Clojure's emerging "stack"
of data-related tooling. The problem of usability has emerged only
because the last few years have seen the emergence of powerful new
tools that provide the bedrock for highly performant data-processing
in Clojure.

One of these tools that has become particularly prominent is the
so-called "tech" stack developed by Chris Nurenberger. This "stack"
consists of a low-level library called
[dtype-next](https://github.com/cnuernber/dtype-next), which provides
a method for handling typed arrays or buffers, and another library,
building in part on dtype-next, called
[tech.ml.dataset](https://github.com/techascent/tech.ml.dataset) that
provides a column-based tabular `dataset` much like the "dataframes"
one finds in R or Python's Pandas library.

Using just tech.ml.dataset, one can already perform the kind of data
analyses over large amounts of data that one would when, say,
participting in a Kaggle competition. Indeed, in many cases, thanks to
Chris Nurenberger's amazing work, this stack can outperform equivalent
tools in Python, R, and even Julia.[^1] However, although very usable
tech.ml.dataset does not have a very consistent API. For this reason,
even Chris Nurenberger suggests that most people who are starting out
with Clojure data science will want to turn to another library, the to
which I will be contributing:
[tablecloth](https://github.com/scicloj/tablecloth).

Tablecloth is essentially a wrapper on top of tech.ml.dataset.
Authored by Tomasz Sulej, who has authored many other libraries and
has a knack for creating beautiful and consistent syntax, it provides
a beautiful and consistent API for interacting with `datasets` that is
inspired by the user-friendly syntax of R's tidyverse libraries among
others.

## My Project: Columns for Tablecloth

What I will work on during this project, then is adding a new
dimension to tablecloth's API. Currently, the focus of tablecloth's
API is the `dataset`. This, of course, makes perfect sense since in
many cases when working with data, especially when manipulating data
as a preparation for feature engineering or some such, you are working
primarily at the level of the whole `dataset`.

There are times, however, when you may want to perform operations not
across a whole dataset (or set of columns), but on a single column. So
what this project will seek to do is add a new API for the `column`. 

In other words, once we've added this API we should, at the very
least, be able to handle an expression like:

```clojure
(def a (column [20 30 40 50]))
(def b (column (range 4)))
(- a b)
;; => [20 29 38 47]
```

The goal in other words is to make the `column`, like the `dataset`, a
first-class primitive within the tech stack. Like R's vectors and
Numpy's `array`, the hope is that when people are working with
tablecloth, users can reach for the `column` when they need to do some
focused processing on a 1d (or perhaps 2d set of items).

## Some Limitations & Oddities

When I originally conceived of this project, I thought what we might
be doing is bringing full-fledged support for n-dimensional arrays
into tablecloth. Indeed, I orgiinally conceived of the project as an
adjunct library called `tablecloth.array`. My thought was that this
distinct library might eschew altogether the reference to
`tech.ml.dataset` -- which has some startup costs -- and simply rely
on the lower-level library dtype-next, which has the key tools for
efficient array processing and is in fact the basis for
tech.ml.datset's columns.

However, for a number of reasons this is not practical. First, there
is already a very strong entry for array processing in the Clojure
world: the [neanderathal](https://github.com/uncomplicate/neanderthal)
library by Dragan Djuric
([@draganrocks](https://twitter.com/draganrocks)). Second, dtype-next
is so low-level that some of the things that one might need, such as
automatic scanning of the items in an array to determine their
datatype, are not present by default. Those features, right now
anyway, only exist within tech.ml.dataset's `Column` type. As such,
what we decided to do is build directly on the tech.ml.dataset's
`Column` as we get so much for free.

One consequence of this approach, however, is that we can not easily
add n-dimensional support. The `column` in tech.ml.dataset, as the
name might suggest, is not designed for multi-dimensionality. It is
built on a single dtype-next buffer. There are possible approaches for
layering on support for n-dimensionality, for example, as Chris
Nurenberger put it:

> [A]s far as if a column could be N-D, you can take a linear random access
> array and make it ND via an addressing operator...[^2]

This solution sounds like a promising approach, but involves
sufficient complexity that I think it will remain out of scope for
this project. Another idea that was batted around briefly was whether
we could support just two dimensions if we, allowed tablecloth's
column api to pass around a dataset internally as a kind of
representation of a two dimensional matrix.

However, I think ghosting behind these technical implementation
questions is a more general question of what people need. The impetus
for this project was about usability. We already have powerful tools
such as neanderthal and core.matrix that handle matrix operations.
What we wanted was to build support for those kind of operations
within the syntactical vernacular of tablecloth, which so many people
have found pleasant to use. It's about making it so that users don't
need to change tools and with it their whole mental model for working
with the tool they are using.

Yet I think it is fair to say we still don't know what people really
need in this space. In that respect, I think of this project as an
experiment. It is better that we do not go whole hog and try to get
n-dimensions right away. What we'll do first is try to build a
sensible column API for tablecloth and then see how (and if) it is
used. Perhaps there will be a need for more dimensions; perhaps not. 

## What I've done so far

Now for what work has been done so far. At this point in the project,
there is a single pull request open on tablecloth. This
[PR](https://github.com/scicloj/tablecloth/pull/71) is a relatively
simple thing. It does two things:

1. It establishes a new api domain: `tablecloth.column.api`. Rather
   than mixing column support into tablecloth's main api
   (`tablecloth.api`), Tomasz suggested we keep it distinct. This
   should help clarify both for implementation and use when we are
   dealing with a column and when we are dealing with a dataset, and
   operations on those entities. It also means that we don't end up
   with naming colisions.
2. It adds a basic set of core functions that establish the `column`
   primitive. These are:
   - `column` - creates a column
   - `column?` - identifies a column
   - `typeof`/`typeof?` - identify the datatypes of the column's elements
   - `ones` / `zeros` - create columns filled with ones or zeros
   
There's not a whole lot to say about these functions that is probably
not rather obvious. One thing to note is that the inspiration is here
being taken from both the R and Python worlds. R uses the name
`typeof` for its typed "atomic" vectors, and Python's Numpy uses the
functions `ones` and `zeros`.

## Next steps

I believe the next steps will be to build out from this simple core of
functions making it possible to do more with columns. This means
considering either basic operations or indexing, slicing, and
iterating over columns.



[^1]: Chris Nurenberger, "High Performance Data with Clojure."
    *YouTube*, 9 June 2021, https://youtu.be/5mUGu4RlwKE.
[^2]: Chris Nurenberger. Message posted to #data-science channel,
    topic "matrix muliplication in dtype-next". *Clojurians Zulip*, 20
    September 2021.
  
