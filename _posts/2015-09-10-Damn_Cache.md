---
layout: news_item
title: Damn Cache
date: 2015-09-10 12:50:34
author: deepreef
---

Damn!  I just discovered that the background processing of identifiers associated with new objects (i.e., data objects not already in BioGUID.org) is extremely processor intensive, due to the cache updating and subsequent generation of full-text indexes. Not only does this slow the data import process for batch uploads, but it turns out that it brings the server to its knees. Obviously, we'll need to re-architect the batch import process (perhaps dividing large batches into smaller batches), but that will have to wait until we return to Hawaii. Until then, expect BioGUID.org to be slow or non-responsive while large datasets (more than a few thousand records) are imported.
