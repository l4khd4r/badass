---
tags: [reference, obsidian]
aliases: [Obsidian customization, Make Obsidian pretty]
---

# Obsidian setup — make the app look and work better

← [[00 Home]]

A checklist to customize **Obsidian itself** (theme, settings, plugins, CSS), tuned for this vault. Do the steps in order; each one is independent, so stop whenever you like it.

> [!tip] Where everything lives
> Settings = ⚙️ bottom-left (or `Ctrl + ,`). Command palette = `Ctrl + P` — you can type the name of any setting or command there.

---

## 1. Built-in settings (2 minutes, biggest win)

### Appearance
- [x] **Base color scheme** → *Dark* (or *Adapt to system*)
- [x] **Accent color** → pick one (e.g. a green like `#3fb27f`, matches P3 in the snippet below)
- [x] **Show inline title** → on (the note name becomes a big title at the top)
- [x] **Show tab title bar** → off (cleaner)
- [x] **Font** → Interface/Text: `Inter`; Monospace: `JetBrains Mono` (install the fonts on your system first: `sudo pacman -S inter-font ttf-jetbrains-mono`)
- [x] **Font size** → 16–17
- [x] **Zoom level** → to taste

### Editor
- [x] **Default view for new tabs** → *Reading view* (notes look finished; `Ctrl + E` toggles editing)
- [x] **Readable line length** → on
- [x] **Show line numbers** → off
- [x] **Fold heading** + **Fold indent** → on (collapse long notes like the P3 ones)
- [x] **Strict line breaks** → off

### Files and links
- [x] **Default location for new attachments** → *In the folder specified below* → `images`
- [x] **Automatically update internal links** → on (rename a note safely)

---

## 2. A theme

*Settings → Appearance → Themes → Manage*. Good ones, all popular and maintained:

| Theme | Style | Why for this vault |
|---|---|---|
| **Minimal** (by kepano) | clean, very configurable | the reference theme; great tables and callouts. Pair it with the *Minimal Theme Settings* + *Style Settings* plugins |
| **AnuPpuccin** | colourful, Catppuccin palette | rainbow folders, pretty headings |
| **Things** | light & airy, inspired by the Things app | very readable for long notes |
| **Catppuccin** | soft pastel dark | easy on the eyes at night |

> [!example] Recommended combo
> **Minimal** + **Style Settings** plugin → in Style Settings: *Minimal → Color scheme* = "Atom" or "Nord", *Tables → full width*, *Images → grid* on.

---

## 3. The CSS snippet made for this vault

Already created at `docs/.obsidian/snippets/badass.css`. Turn it on:

*Settings → Appearance → CSS snippets* → click ⟳ (reload) → toggle **badass**.

What it does:

| Element | Change |
|---|---|
| File explorer | P1 blue, P2 amber, P3 green, Concepts purple, Reference grey; `00 Home` bold |
| Headings | heavier H1, accent-coloured H2 with an underline |
| Tables | full width, zebra rows, header background, rounded |
| Mermaid diagrams | centred, never overflow the page |
| Images / code blocks / callouts | rounded corners, soft borders |
| Tags `#p1 #p2 #p3 #concept` | coloured pills matching the folders |

Edit the colours at the top of the file (`--badass-p1` …). Changes apply instantly.

---

## 4. Colour the graph view

Open the graph (`Ctrl + G`) → ⚙️ → **Groups** → *New group* for each:

| Query | Colour |
|---|---|
| `path:P1` | blue `#4f9dde` |
| `path:P2` | amber `#e0a030` |
| `path:P3` | green `#3fb27f` |
| `path:Concepts` | purple `#a77de0` |
| `path:Reference` | grey `#8a8f98` |

Then in **Display**: *Arrows* on, *Node size* a bit up; in **Filters**: *Attachments* off (hides screenshots).
You'll see P2/P3 notes clustering around VXLAN / EVPN concepts — a nice visual for the [[Concept Map]].

---

## 5. Core plugins to turn on

*Settings → Core plugins*:

- [ ] **Bookmarks** → bookmark [[00 Home]], [[Concept Map]], [[Commands Cheatsheet]], [[Defense Q&A]]
- [ ] **Outline** → right sidebar table of contents for the current note (great for P3 notes)
- [ ] **Backlinks** (show at the bottom of notes) → see which notes point here
- [ ] **Page preview** → hover a `[[link]]` with `Ctrl` to preview it
- [ ] **Workspaces** → save a layout: Home on the left, P3 note in the middle, Graph on the right
- [ ] **Slides** → present any note as slides (separate slides with `---`) — handy for the defense

---

## 6. Community plugins worth installing

*Settings → Community plugins → Turn on → Browse*.

| Plugin | What it gives you |
|---|---|
| **Style Settings** | GUI for theme + snippet options (needed for Minimal) |
| **Iconize** | icons next to folders/notes (🐳 P1, 🚇 P2, 🌐 P3…) |
| **Homepage** | always open [[00 Home]] on startup |
| **Excalidraw** | draw your own topology diagrams by hand, embedded in notes |
| **Dataview** | auto-generated lists, e.g. every note tagged `#p3` |
| **Spaced Repetition** | turns [[Defense Q&A]] into flashcards for revision |
| **Advanced Tables** | easy editing of all the tables in this vault |
| **Omnisearch** | much better search than the built-in one |
| **Commander** | add buttons (e.g. "Open graph") to the toolbar |

> [!warning] Community plugins run code
> Install only well-known ones (high download count, recently updated). Each one stores its
> settings in `.obsidian/plugins/`, which is git-ignored here.

### Example: a Dataview list of P3 notes

Once Dataview is installed, this block renders a live list:

````markdown
```dataview
LIST FROM #p3 SORT file.name ASC
```
````

---

## 7. Useful shortcuts

| Shortcut | Action |
|---|---|
| `Ctrl + O` | quick switcher (open any note by name) |
| `Ctrl + P` | command palette |
| `Ctrl + E` | toggle reading / editing |
| `Ctrl + G` | graph view |
| `Ctrl + click` link | open in new tab |
| `Ctrl + Alt + ←/→` | back / forward |
| `Ctrl + Shift + F` | search in all files |
