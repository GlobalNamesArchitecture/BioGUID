---
layout: news_item
title: Memory Leak seems to be Solved
date: 2015-10-06 06:24:34
author: deepreef
---

Well.... there's good news, and there's bad news.  The good news is that, after some 20 hours (ish), the memory leak problem seems to be solved! (Woo-hoo!)  The bad news is that I can't be sure if it's really solved, because I have a new (separate) issue with Tomcat eating up all my server CPU.  SQL's also pegged out (as it can be at times when there is heavy usage), but Tomcat is saturating the CPU usage (which almost never happens), so something else seems to be happening now.  I don't think my fixes of the memory leak issue touched Tomcat, so I suspect it's an unrelated issue.  The problem is: I don't know whether I really solved the memory leak problem, or if the runaway Tomcat thing has just masked it (i.e., prevented it from happening by saturating the server).  If Only I were a real computer programmer, instead of a taxonomist, I wouldn't feel like such a noob all the time.  Sigh.  OK, it will probably be a long night (again)....
