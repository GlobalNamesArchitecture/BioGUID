---
layout: news_item
title: Email Addresses Hidden
date: 2015-10-08 06:42:53
author: deepreef
---

I noticed that earlier today someone batch-uploaded a dataset that contained several email addresses as identifiers mapped to Agents. The import was successful, and the identifiers were correctly incorporated into the BioGUID.org index.  However, email addresses are one of the few Identifier Domains that is classified as "Hidden". This means that the results are not displayed in the search output. For obvious reasons, we don't want to expose email addresses on a web service such as this.  However, we might want to use BioGUID as a way of locating people when you already have an email address.  For example, if I search for '[8C466CBE-3F7D-4DC9-8CBD-26DD3F57E212]' (my ZooBank/GNUB UUID), I don't want my email address included in the results.  However, if I search BioGuid.org for "deepreef@bishopmuseum.org", I see no reason why I shouldn't display the results of other identifiers mapped to me (including my ZooBank/GNUB UUID).  I'll give this some thought.

[8C466CBE-3F7D-4DC9-8CBD-26DD3F57E212]: http://bioguid.org/searchIdentifier?q=8C466CBE-3F7D-4DC9-8CBD-26DD3F57E212&format=html