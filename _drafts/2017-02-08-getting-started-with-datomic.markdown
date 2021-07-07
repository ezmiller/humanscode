---
layout: post
title:  "Setting up a Datomic Client"
author: Ethan Miller
date:   2017-02-11
categories: tutorials
tags:
- databases
---

I've been experimenting with an exciting new database called Datomic. Datomic is particularly interesting because it has been implmented differently than any other database that I'm familiar with. Two characteristics, in particular, interest me.

First, unlike virtually every other database I know, Datomic eschews the "square" tabular structure to store information. Second, Datomic never overwrites your data. When you make a change, it simply adds the new information that you've provided. In this respect, Datomic behaves similarly to versioning tools like git or svn.

For the moment, I won't delve into how Datomic works. I may do that in future posts. What I want to do now is describe how one gets Datomic running because it is none too easy! Datomic's documentation is quite high-level, and it's easy to get lost, especially considering that Datomic's architecture is quite different than most databases.

## Datomic's Architecture

The primary difference between Datomic and other databases in terms of its
architecture is that it is essentially decomposed into distinct parts or
modules. You can't, in other words, just install the database, make sure it's daemon is running, and assume the rest will work. In order to get, your Datomic database running, you need to setup each of these distinct pieces, and you also have some choices to make along the way.

For this all to make sense, it's helpful to have the big picture. Datomic provides a diagram on their page explaining [Datomic's Architecture](http://docs.datomic.com/architecture.html):

{% include figure.html src="/images/datomic-architecture.png" %}

It's worth studying this diagram for a minute, but be aware that the diagram is also describing two-possible ways of setting up your system. Specifically, you can either set up your system using what they call a "peer", or you can use a "client." Datomic's naming here is exceedingly confusing, at least to the newbie. It's not immediately clear from the naming, what the difference is between a peer and a client; moreover, you'll also notice that there are two modules bearing the name peer in the diagram: the "Peer App Process" and the "Peer Server." It's rather confusing.

Let's try to simplify. First off, the key point here is that when you are setting up your system, you need to decide whether you want to use a "peer" or a "client." Datomic provides detailed discussion of the tradeoffs [here](http://docs.datomic.com/clients-and-peers.html), which begins with this convenient summary: 

> There are two ways to consume Datomic: with an in-process peer library, or with a client library. If you are trying Datomic for the first time, we recommend that you begin with a client library. When you are ready to plan a system, you can return to this page for guidance on whether to use peers, clients, or both.

For the purposes of this tutorial, I've chosen to follow this advice. So what we'll do here is set up access to datomic using a client. That said, I will briefly talk about the different modules that are necessary for both the peer and the client, since that was at least one of the confusions that I encountered when getting setup.

If you look carefully at the diagram, one thing that you'll see is that both the client and the peer setups make use of the "Transactor", the "Storage Server/Service", and the optional "memcached cluster". However, if you are using the "Client App Process" (i.e. client) then you will also need to use the "Peer Server". And this is where things get confusing for the newbie. So please note well: the "Peer Server" is not the same as or related to the "Peer" setup in Datomic. Rather, the "Peer Server" is necessary if you want to use the client to access datomic.

Simplified, the two setups look like this:

(Client App => Peer Server => Transactor => Storage Service)  
(Peer App => Transactor => Storage Service)

That's the high-level view for the most part, with one further caveat, which is that the one can also run the peer server in such a way that the database is run only in memory and the transactor and storage service are not necessary. This, in fact, is the method that is demonstrated in Datomic's "Geting Started" tutorial.
