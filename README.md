# An Introduction to Analyzing Political Texts

***Note: the materials should be ready to go now, but I would suggest waiting until just before class begins to download them to your local machine.**

This repository has materials (code, data, slides) for my one day course at Yale University, on November 15, 2019. The course consists of a
* lecture component
* programming/applied component in [R](https://www.r-project.org/)

The course requires absolutely *no* previous experience with working with texts.  But it *does* require some experience working with R.  In particular, you will get most out of the course if you have taken at least one undergraduate or graduate class that involved the use of R.


## Location
[Luce Hall](https://conferencesandevents.yale.edu/about-us/venues/luce-hall), Room 202. Luce Hall is in the Center of International Studies, 34 Hillhouse Avenue.

## Schedule
The workshop is from 10am to 4pm.  The schedule for the day is: 
* 10am-noon: Lecture
  * characterizing text
  * vector space model and "bag-of-words"
  * similarity measures
  * keywords in context
  * complexity/readability
  * uncertainty for texts
  * burstiness and style (time permitting)
* noon-1230pm: R exercises

* 1230--2pm: lunch

* 2-330pm: Lecture
  * Supervised learning: dictionaries/sentiment, "WordScores"
  * Unsupervised learning: Topic Models 
* 330pm--4pm: R exercises.

## Materials
Lectures will appear here: [lectures](https://github.com/ArthurSpirling/yale_text_course/tree/master/course_lectures)

R Materials will appear here: [code](https://github.com/ArthurSpirling/yale_text_course/tree/master/R_code)  (download to your local machine). 

Data will appear here: [data](https://github.com/ArthurSpirling/yale_text_course/tree/master/data) (download to your local  machine)

## Readings and Packages
For the R exercises, you will need to install:
* `quanteda`
* `readtext`
* `lsa`
* `bursts`
* `topicmodels`
* `ldatuning`

There are no *required* readings, but the following may be helpful if you have further interest in the topics we cover:

### Overview and Preprocessing
* Grimmer, Justin, and Brandon M. Stewart. "Text as data: The promise and pitfalls of automatic content analysis methods for political texts." Political analysis 21.3 (2013): 267-297.
* Denny, Matthew J., and Arthur Spirling. "Text preprocessing for unsupervised learning: Why it matters, when it misleads, and what to do about it." Political Analysis 26.2 (2018): 168-189.

### Complexity
* Benoit, Kenneth, Kevin Munger, and Arthur Spirling. "Measuring and explaining political sophistication through textual complexity." American Journal of Political Science 63.2 (2019): 491-508.
* Spirling, Arthur. "Democratization and linguistic complexity: The effect of franchise extension on parliamentary discourse, 1832–1915." The Journal of Politics 78.1 (2016): 120-136.

### Style
* Mosteller, Frederick, and David L. Wallace. "Inference in an authorship problem: A comparative study of discrimination methods applied to the authorship of the disputed Federalist Papers." Journal of the American Statistical Association 58.302 (1963): 275-309.
* Spirling, Arthur, Leslie Huang, and Patrick O. Perry. "A General Model of Author “Style” with Application to the UK House of Commons, 1935–2018." [here](https://www.nyu.edu/projects/spirling/documents/VeryBoring.pdf)

### Burstiness
* Eggers, Andrew C., and Arthur Spirling. "The shadow cabinet in Westminster systems: modeling opposition agenda setting in the House of Commons, 1832–1915." British Journal of Political Science 48.2 (2018): 343-367.

### Supervised Learning (Wordscores)
* Laver, Michael, Kenneth Benoit, and John Garry. "Extracting policy positions from political texts using words as data." American political science review 97.2 (2003): 311-331.

### Unsupervised Learning (Topic Models)
* David M. Blei. 2012. Probabilistic topic models. Commun. ACM 55, 4 (April 2012), 77-84. DOI: https://doi.org/10.1145/2133806.2133826
* Roberts, Margaret E., et al. "Structural topic models for open‐ended survey responses." American Journal of Political Science 58.4 (2014): 1064-1082.



