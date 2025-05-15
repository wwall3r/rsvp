# rsvp (via gleam + htmx)

## Setup 

  * Install [docker](https://docs.docker.com/get-docker/) or [podman](https://podman.io) (not required, but recommended)
  * Install [asdf](https://github.com/asdf-vm/asdf) version manager.
  * Install [asdf-gleam plugin](https://github.com/asdf-community/asdf-gleam)
  * Install [asdf-rebar plugin](https://github.com/Stratus3D/asdf-rebar)
  * Install [asdf-erlang plugin](https://github.com/asdf-vm/asdf-erlang)
  * `asdf install`
  * Install `node`
  * Install `pnpm` (typically either with `corepack enable` or `brew`)
  * `pnpm install`
  * Install `watchexec` (typically with `brew` or system package manager)

## Development
Copy `.env.example` to `.env` and update the values if you like

```sh
podman compose up # start db and jaeger
./watch.sh  # run the server and watch for changes
gleam run   # Run the project
gleam test  # Run the tests
```

## Decisions

### Why?

Because both evite and punchbowl pissed me off in the span of a week. Even most
of the smaller ones out there were just... clunky and expensive.

### Why Gleam?

I did Advent of Code in Gleam in 2024 and liked it a lot. I wanted to try a 
project that is not trivial (like todos) but also not so hard that I couldn't 
switch out for another stack (or just get AI to help implement in another stack
for comparison). I already have some other side projects in Elixir and I really
like the BEAM VM for web work.

### Why HTMX and not Lustre?

I considered it. I still might roll a version/branch with Lustre, especially now that
they have dropped React as the internal engine (too much React-related trauma
and if you ever see it in my side projects you can assume I am under duress). If
I were to try it, I'd probably do a local-first setup using [`lustre`](https://hexdocs.pm/lustre/index.html) 
and [`omnimessage`](https://github.com/weedonandscott/omnimessage).
However, that seems like massive overkill for what the project is. Where I need
a sprinkling of JS, I'll probably just use a web component and write it directly in JS.

### Database?

* [`cigogne`](https://hexdocs.pm/cigogne/index.html) for migrations (so far so good; needs a `reset` command though)
* [`squirrel`](https://hexdocs.pm/squirrel/index.html) for code gen from SQL

Squirrel is really nice so far. I wish I had a little more control over the template
and types that are used (e.g. would like it to use my `User` type with phantom types
for IDs), but overall really nice experience and I just get to write SQL.

### Why Progressive Enhancement?

Everyone agrees it is better, but that it is too hard for most shops to consider attempting
unless they know a good chunk of their market is gonna need it. This is small 
enough to let me experiment and find out exactly what the pain points are.

### Why Pico CSS and no tailwind?

Tailwind is fine. I've used it in a lot of other projects and would probably consider
it on this one if it was a larger effort. The goal here is to use more semantic HTML
and be able to swap stylesheets to potentially spruce up the event pages. Typically
I don't believe in HTML/CSS as a true separation of concerns, but when you consider
that particular requirement it becomes more attractive. Plus I do not have much in 
the way of highly custom components for this.

We may need a CSS build at some point just to be able to split out from one file and
minify.
