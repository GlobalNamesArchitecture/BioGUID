---
layout: news_item
title: Import Performance Tests
date: 2015-10-08 11:55:55
author: deepreef
---

Another late night...sigh... I wanted to do some performance tweaking on the bulk data import process, so I set up a series of import dataset CSV files, one containing 10 records, one containing 100 records, one containing 1,000 records, one containing 10,000 records, one containing 100,000 records, and one containing 475,574 records. Unfortunately, my import routine crashed on the first dataset (10 records). Surely the problem must be related to the new performance monitoring code I added to the routine. Right?  Nope.  SIX hours of frustrating hair-pulling later, I finally sleuthed out the bug, which was related to a rare circumstance that just HAPPENED to be represented in those first ten random records. (Note to self: no one wins when you try to find an obscure bug on dense code when you're sleep deprived. No one.) In any case, the 100,000 record batch took about 2 minutes to complete, and the 475,574 record batch took about 15 minutes to complete.  Not bad, but not great.  More performance tuning is in order, methinks.
