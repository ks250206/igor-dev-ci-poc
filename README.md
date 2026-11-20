# igor-dev-ci-poc

An Igor Pro 8.04 procedure that draws a Lissajous curve from a GUI panel, with static checks in GitHub Actions.

## Lissajous curve panel (`procedures/Lissajous.ipf`)

```
x(t) = sin(a·t + δ)
y(t) = sin(b·t)        (t = 0 … 2π)
```

### How to use

1. In Igor Pro 8.04, open `procedures/Lissajous.ipf` and compile it.
2. Choose **Macros > Lissajous Panel** from the menu, or run `Lissajous_ShowPanel()` on the command line.
3. Click **Draw Lissajous** to open the graph.
4. When you change `a` / `b` / `delta` in the number boxes, the graph redraws immediately.

### Graph settings

| Item | Setting |
| --- | --- |
| Magnification | `ModifyGraph expand=2` |
| Font size | `ModifyGraph fSize=12` |
| Axis label font size | `\Z16` in the `Label` text |
| Mirror axes (top / right) | `ModifyGraph mirror=1` |
| Tick direction | Inward (`ModifyGraph tick=2`) |

The data lives in `root:Packages:Lissajous` (`gA`, `gB`, `gDelta`, `lissX`, `lissY`).

## CI (GitHub Actions)

`.github/workflows/igorpro.yml` runs `ipt check` and `ipt lint` on every tracked `.ipf` file. It runs on push and pull requests that change an `.ipf` file or the workflow, and can also be started manually with `workflow_dispatch`.

- It downloads the official Linux build of [IPT (Igor Programming Tool)](https://docs.byte-physics.de/ipt/) each time it runs.
- **IPT builds expire 3 months after release.** If the latest build has expired, CI fails. When that happens, wait for a new IPT release and run CI again.
- The workflow does not pin the IPT version or SHA-256. For production use, add checksum verification.
- CI does **not** compile the procedure in Igor Pro itself. Passing IPT does not mean the code compiles in Igor Pro 8.04.

## Development skill

This repository uses [assb-lab/igorpro-dev-skills](https://github.com/assb-lab/igorpro-dev-skills) (`igorpro-8-development`), installed under `.agents/skills/`:

```bash
npx skills add assb-lab/igorpro-dev-skills --skill igorpro-8-development
```
