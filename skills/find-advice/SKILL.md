---
name: find-advice
description: >
  Look something up on the web and bring back a short answer where every point names the page it
  came from. Use when the user says "find advice on X", "what's the best way to X", "how do people
  usually X", "look this up", or needs a current fact the AI can't know from memory (a price, a
  deadline, a version, an office's rule). Uses OpenCode's built-in `websearch` tool (it asks
  before each search) and `webfetch` to read one page. If a real decision rests on the answer,
  `primary-source` digs deeper.
---

# Find advice

> Every point in the answer comes from a page you actually got back from a search or a fetch.
> No page, no point. Searching reads pages; it never clicks, logs in or fills in a form.

## Off-switch

"Just tell me what you think" → answer from memory, and say at the top: *"Not looked up. From
memory, may be out of date."*

## Steps

### Step 1 — pin the question
Say the question back in one line. Too vague to search → ask one question: *"What is this for?
What will you do with the answer?"* The first search of the session, also say once: *"Searching
sends your question (not your files) to a web search service run by another company. OpenCode
asks before each search; you can say no."*

### Step 2 — search
Use the `websearch` tool with a short query (3 to 8 words). At most 3 searches per question.
Never put a name, address, account number or anything from `private\` into a query.
No `websearch` tool, or the user said no → ask them to type a search into their own browser and
paste back the address of the best page; then go to Step 3 with that address.

### Step 3 — read the closest pages
Pick at most 3 results closest to the source: the official site, the maker's own help pages, a
government page, someone who did it and wrote it up. Read a page with `webfetch` (it asks first)
when the search snippet doesn't hold the exact sentence you need. A page that won't load is not
evidence either way: say it didn't load.

### Step 4 — answer in this shape

```
Question: <one line>
1. <the advice, one line> — "<short quote from the page>" — <address>
2. ...
3. ...
Watch out: <one warning the pages give, if any>
Not found: <what the pages did not answer>
Looked up: <today's date from Get-Date>
```

Numbers, dates and prices copied exactly from the page. The page doesn't say it → leave it out,
or put it under Not found.

### Step 5 — offer to save
Ask: *"Save this to `notes\advice-<topic>.md`?"* Write only after a yes. The user is about to
spend money, sign, send or build on this → offer `primary-source` first.

## If the built-in search is missing

The built-in `websearch` works with the OpenCode and OpenCode Go providers; with another
provider it may not appear. One option is Tavily (tavily.com), a search service you can add to
OpenCode as an MCP server (opencode.ai/docs/mcp-servers). It needs your own key: keep the key in
a file that `.gitignore` covers, never in `opencode.json` or in chat. Not tested with this kit.

## Avoid

- A point with no address, or an address you did not get back from a search or a fetch.
- A number from a search summary that you did not find on the page itself.
- Clicking, logging in or filling in forms. Search can't do that; don't try another way.
- Private details in a search query.

Tested with: OpenCode 1.18.32 + opencode-go/deepseek-v4.1-flash (2026-09-30). Not tested on other systems.
