# Promoting staging to live

Staging: https://next.superduperintelligence.ca (this repo, anticontainmentsystem/superduperintelligence-next)
Live: https://superduperintelligence.ca (anticontainmentsystem/superduperintelligence)

Every change lands here first. Promote only after Ninetentwo approves it on staging.

## How

    ./promote.sh "v=10: what changed"

The script:

1. Pulls both repos.
2. Copies every staging file into the live repo, except CNAME, robots.txt, PROMOTE.md and promote.sh.
3. Restores the live settings: CNAME superduperintelligence.ca, robots.txt Allow all with the sitemap, robots meta index,follow, and the title without the "NEXT | " prefix.
4. Commits as anticontainmentsystem and pushes. GitHub Pages serves it within a minute or two.

Then check https://superduperintelligence.ca loads the new ?v= number.

## Staging differences (keep these here)

- CNAME is next.superduperintelligence.ca.
- robots meta is noindex,nofollow and robots.txt disallows everything.
- The page title starts with "NEXT | ". Nothing else looks different.
- Canonical and Open Graph URLs still point at the main domain.

The relay (sdi-relay) accepts both origins, so staging calls the same Oracle, Judge, Guide and Suggest.
