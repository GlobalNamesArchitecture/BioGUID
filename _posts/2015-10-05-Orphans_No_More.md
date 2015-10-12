---
layout: news_item
title: Orphans No More
date: 2015-10-05 02:29:53
author: deepreef
---

The missing object records for the orphan Identifiers have now been completely generated. There were over 150 thousand of them, but because of the way SQL works to find such orphans (i.e., via an outer Join with missing link, or via a "NOT IN" WHERE clause), it actually takes a long time to find them all.  At first, I was able to find them in batches of about 10,000 in 10 minutes (also allowing the server an additional half hour between each batch to update full-text indexing across the billion identifiers and half-billion objects).  However, the fewer orphans there are, the longer it takes SQL to find them.  The last three missing records took 3 hours and 42 minutes to find!  Once the missing object records were created, it took an additional 2 hours to apply the referential integrity constraints on the database (again, a billion identifiers cross-linked to a half-billion object records) to prevent any more such orphan identifiers in the future. The site was slowed to a crawl during this time, but the dust now finally seems to be settled, so BiOGUID should be back up and running again at normal speeds.
