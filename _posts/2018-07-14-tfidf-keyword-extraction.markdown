---
layout: post
title:  "Building a Tf-Idf Keyword Extractor"
author: Ethan Miller
date:   2018-07-14 
categories: natural-language-processing, data-science, python
---

Automatic keyword extraction is a frequently encountered problem in natural language processing that poses some interesting challenges. The task of an automatic keyword extractor is to extract set of words and/or phrases that effectively summarize a given text.

Such a tool can be useful in a variety of situations. Generating keywords for human consumption is one use. Additionally, because keyword extraction transforms unstructured data (the original text in all its  messiness) into a more structured form (the finite set of meaningful keywords), the keywords it produces can also be re-consumed by another alogrithm. For example, keyword extraction can be used to enhance document clustering and categorization, keyword search, and the determination of semantic similarity between texts.

There are a number of different methods, both supervised and unsupervised, for accomplishing keyword extraction. In general, supervised methods are known to perform better but it can be challenging to find an appropriate prelabeled datset. As is always the case with supervised learning, one has to be careful not to overfit one's model to the training data. For a more in depth discusison, plus links to other additional resources, check out this excellent [blog post](https://bdewilde.github.io/blog/2014/09/23/intro-to-automatic-keyphrase-extraction/) by Burton DeWilde which I relied on heavily also in my coding up my solution.[^1]

For my purposes, I chose an unsupervised method because I hoped to use the keyword extractor on texts whose topical domain is arbitary and unknown. I also wanted to start with the easiest method to implement, so I chose Tf-Idf.

### What is Tf-Idf?

Tf-Idf is simple model for the evaluation of unstructured texts that breaks documents into unitary words or phrases (aka tokens) and then scores their relevance as a function of their frequency of use and their uniqueness within a given corpus. It breaks down like this:

* $Tf = Term Frequency$
* $Idf = \text{Inverse Document Frequency}$

And the scoring function looks like this:

$$\text{relevance score} = TF \times IDF$$

Essentially, these are two distinct representations, with different assumption, that are combined to produce the final weighting.

The first representation of relevance, **term frequency**, is based on the following principle, as expressed by in Hans Peter Luhn in 1952:

> The weight of a term that occurs in a document is simply proportional to the term frequency.[^2]

This makes sense, right? The more an author uses a word, the more important it must be.

Well, what about words like "the" or "a"? We all use those words all the time and they really aren't helpful in determining meaning beyond their syntactical/structural value. If we used term frequency on its own we'd might get some odd results. We could just filter out words like a and the (frequently known as stop words) -- and in most cases we would -- but the same problem with other words that we use frequently but don't carry all that much summarial value.

To compensate for this inadequacy in term frequency, we can combine term ferquency with **inverse document frequency**. This weighting is a measure of how *rare* a word or phrase is in a set of documents or corpus.  It is based on the following assumption, as described by Karen Jones in 1972:

> The specificity of a term can be quantified as an inverse function of the number of documents in which it occursk [^3]

In other words, the rarer a word is across an entire corpus, the more specific its meaning is to the document in which it occurs and the more important it may be in summarizing that document.

Alone either one of these models is more imperfect than they are together. So we put them together:

$$Tf \cdot Idf$$

That is Tf-Idf in its essence. There are a few other considerations when it comes to normalization, for example it's common to take the log of the inverse document frequency as well as the term frequency weights, but let's leave that theme aside for now.[^4]

### Implementing Keyword Extraction with Tf-Idf

As with most keyword extraction processes, the method for extracting keywords with Tf-Idf is a two-step process: First, you extract a set of candidate keywords and phrases and then you score them with a Tf-Idf model. In order to do this, however, you already need to have built a Tf-Idf model based on some corpus.

Prepping the Tf-Idf model is a bit like training, only you aren't fine-tuning some sort of predictive function. Instead, you are establishing two important parameters: 1) You are specifying the set of words and/or phrases that will be scorable in the first place (i.e., the words and phrases contained in the corpus or some subset of them), and 2) you are defining the body of texts against which the inverse document frequency will be calculated.

The choice of corpus is therefore consequential. If you choose a corpus whose subject domain varies greatly from the texts you are likely to score, many of the important words in a given text will simply be dropped.

For my purposes, I chose to use the so-called Brown Corpus, short for Brown University Standard Corpus of Present-Day American English. The Brown Corpus is an easy-to-obtain collection of 500 texts, compiled in 1961 by a couple of Brown University linguists, which was intended to be representive of contemporary American English (circa 1961). It seemed like a suitable place to start -- although obviously it would exclude newer phrasings. There are several other, much larger corpora available -- in particular the entire dump of English language Wikpedia texts -- that I may try in the future.

To keep things short in terms of code examples, I'm not going to walk though the steps to create the Tf-Idf model here in the post. However, I've created a jupyter notebook where you can execute the code directly and walk through each step [here](https://mybinder.org/v2/gh/ezmiller/keymo/master?filepath=binder%2Fbuilding-tfidf-from-brown-corpus-bigrams.ipynb) using the amazing [binder](http://mybinder.org) tool for sharing notebooks. So please take a look at that.

So let's assume that we already have a tf-idf model. Here's what we'd do to extract the keywords:

Candidate selection is a really important step becuase the fact is that we can rule out a great many words and phrases that just won't be useful when summarizing the text. So we want to be pretty selective at this stage. One very effective way to accompolish this goal is to use part-of-speech-tagging (POS) to select certain types of unigrams and bigram pairs.

Here are some functions that accomplish that goal, relying heavily on the nltk methods:

```
def get_pairs(phrase, tag_combos=[('JJ', 'NN')]):
    tagged = nltk.pos_tag(nltk.word_tokenize(phrase))
    bigrams = nltk.ngrams(tagged, 2)
    for bigram in bigrams:
        tokens, tags = zip(*bigram)
        if tags in tag_combos:
            yield tokens


def get_unigrams(phrase, tags=('NN')):
    tagged = nltk.pos_tag(nltk.word_tokenize(phrase))
    return ((unigram,) for unigram, tag in tagged if tag in tags)


def get_tokens(doc):
    unigram_tags = ('NNP', 'NN')
    bigram_tag_combos = (('JJ', 'NN'), ('JJ', 'NNS'), ('JJR', 'NN'), ('JJR', 'NNS'))
    unigrams = list(get_unigrams(doc, tags=unigram_tags))
    bigrams = list(get_pairs(doc, tag_combos=bigram_tag_combos))
    return unigrams + bigrams
```

From here, the process of scoring is quite simple. Given a new document, you extract the candidates and then score them. Finally, you could also select some number, let's say 10, of the top candidates. To score and then rank the results we can use the following function:

```
def get_keywords(text, model, vocab, num_keywords):
    tokens = [" ".join(x) for x in get_tokens(text)]
    bow = vocab.doc2bow(tokens)
    scores = model[bow]
    sorted_list = sorted(scores, key=lambda x: x[1], reverse=True)
    for word_id, score in sorted_list[:num_keywords]:
        yield vocab[word_id], score]
```

This function takes in the text from which which we'd like to extract the keywords, our Tf-Idf model, and our vocab. Given these, it extracts the candidates using our `get_tokens` function, generates a bag-of-words representation from those candidates, and then scores them. Finally, it ranks the list and returns a generator with the keyword and its score.

### Performance

So how well does this work? Well, the result are mixed I would say. Let's take a random blurb, some notes that I took about the philospher Hegel's take on marriage (random I know):

```
sample_text = """
Just in the case of contract it is the explicit
stipulation, which constitutes the true transference of property
(§ 79), so in the case of the ethical bond of marriage
the public celebration of consent, and the corresponding
recognition and acceptance of it by the family and the
community, constitute its consummation and reality. The
function of the church is a separate feature, which is not
to be considered here. Thus the union is established and
completed ethically, only when preceded by social ceremony,
the symbol of language being the most spiritual embodi-
ment of the spiritual (§ 78). The sensual element pertain-
ing to the natural life has place in the ethical relation only
as an after result and accident belonging to the external
reality of the ethical union. The union can be expressed
fully only in mutual love and assistance.
"""
```

Now we can call our function on this blurb, providing the Tf-Idf model and the vocabulary. And we get:

```
[
    [
        "union",
        0.3997340417677787
    ],
    [
        "stipulation",
        0.2943272612593516
    ],
    [
        "consummation",
        0.2943272612593516
    ],
    [
        "natural life",
        0.2943272612593516
    ],
    [
        "mutual love",
        0.2943272612593516
    ],
    [
        "transference",
        0.2943272612593516
    ],
    [
        "reality",
        0.22001701826569206
    ],
    [
        "consent",
        0.18076162087590167
    ],
    [
        "belonging",
        0.17284984744748857
    ],
    [
        "celebration",
        0.17284984744748857
    ],
]
```

How can we evaluate this list of keywords? One of the challenging things about keyword summarization is that it can be a subjective exercise. What keywords are most important in any given text might depend on the subjective perception and understanding of the text by the individual.

This is one reason that supervised methods for keyword extraction are superior: because you start with a labeled set of texts that whose keywords are presumably of high quality, the model that you train is one that has a definable objective accuracy tied to the quality of keywords defined on the dataset. Those keywords may still be subjective in nature, but they were likely created by more than one individual so at least they have an subjectivity that goes beyond a single person.

In this case, though, I'll have to fall back on my own intuition. Intuitively, I would have hoped that the word "marriage" topped the list of keywords that we got back. Instead, it's not present at all. The reason it is not present most likely has to do with the fact that in the text the word "union" is used much more frequently as a synonym for marriage. That, and the word "marriage" is actually more common than the word "union" in the Brown-Corpus: marriage occurs in 43 documents and union occurs in 30. So in addition to the fact that union is used more frequently in this blurb, its Idf score is higher than marriage.  As for the other words in the set, it seems odd to me that the word "stipulation" ranks so highly, while "mutual love", "consent", "celebration", and "transference" seem appopriate. In sum, this list seems to have some good selections, but also quite a bit of noise.

Interestingly, the keyword extractor performed better with respect to the word "marriage" when I ran it over the whole set of notes that I'd taken on Hegel. With the whole set, the two top-scoring keywords were "union" at .406 and "marriage" at .303. Better, but arguably you might still like to see union and marriage merged in favor of marriage, since it is the more specific word.

### Conclusions & Future Experiments

Tf-Idf ultimately seems to be a flawed method for extracing keywords. As the example illustrates above, Tf-Idf models simply can't deal with synonyms. It simply has no way of understanding that these words are related, which is a significant limitation. This is because Tf-Idf's method for modeling a text is rooted in tokenization. Each token is considered on its own, and not in relation to any other word. Beyond the problem of word relations, the model also ranked words that seemed obliquely related to the main theme of the text. This latter problem could possibly be improved by building the Tf-Idf model out of a different or larger corpus, something like the English Wikipedia corpus.

Going forward, there are a couple of different directions that I'd like to go. I would in fact like to try building a Tf-Idf model from a much larger dataset that is also more up-to-date. I wonder if a much larger corpus might improve results by increasing drastically the range of keyword tokens that can be considered, as well as improving the quality of the Idf weights.

Another direction to go would be to try a different set of unsupervised methods, such as TextRank, that seek to evaluate keywords based on a graph-based representation of a document. The tendency in these graph-based representations is to calculate relevance as a function of relatedness. Tokens that have a high degree of relatedness to other tokens, are understood to have a high relevance for the given document.

Finally, I'm very curious about a technique called "word embedding" that can be used for keyword extraction, and this is likely where I will focus future efforts. In a nutshell, word embedding considers words in their context, making it possible to understand the relationships between words. It does this by transforming, words into vector representations, casting them into dimensional space, and then looking at their proximity. That's about the best I can do to describe this method at the moment. But with any luck, I'll present a fuller exploration later.


[^1]: Burton deWilde, "Intro to Automatic Keyphrase Extraction", Burton DeWilde (blog), 22 July 2018 <https://bdewilde.github.io/blog/2014/09/23/intro-to-automatic-keyphrase-extraction/>
[^2]: Hans Peter Luhn, "A Statistical Approach to Mechanized Encoding and Searching of Literary Information", *IBM Journal of Research and Development*, 315 (quoted in "Tf-Idf", Wikipedia.com, 2 July 2018 <https://en.wikipedia.org/wiki/Tf-idf>
[^3]: Karen Jones, "A Statistical Interpretation of Term Specificity and Its Application in Retrieval", *Journal of Documentation* (1972): 28 (quoted in "TF-Idf", Wikipedia.)
[^4]: For details on normalization: "Tf-Idf", Wikipedia.com; "Tf-Idf Term Weighting" in "4.2 Feature Extraction", *Documenation of sci-kit learn 0.19.2*, 22 July 2018 <http://scikit-learn.org/stable/modules/feature_extraction.html#tfidf-term-weighting>
