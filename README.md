# rsvp (via gleam + htmx)

## Setup 

  * Install [docker](https://docs.docker.com/get-docker/) (not required, but recommended)
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

```sh
./watch.sh  # run the server and watch for changes
gleam run   # Run the project
gleam test  # Run the tests
```
