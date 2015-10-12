---
layout: news_item
title: Bug Workaround
date: 2015-10-08 18:39:38
author: deepreef
---

I discovered a bug that prevents uploading identifiers with no value entered for "RelationshipType" in the uploaded CSV.  It should be easy to fix, but for now, the work-around is to make sure you include a value in the "RelationshipType" column of the uploaded file.  If you're only submitting raw identifiers (with no related identifiers), just use "Congruent" for RelationshipType.
