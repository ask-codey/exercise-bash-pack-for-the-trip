# Exercise: Pack for the Trip

Exercise code for the lesson **Exercise: Pack for the Trip** in Bash in Depth on [ask-codey.com](https://www.ask-codey.com).

You leave for Lisbon next week, and the trip folder needs sorting out before you go. Find out what takes up the space with `du` and `df`, give the tickets folder a short name with `ln -s`, pack the documents and the photos into archives with `tar` and `zip`, and look inside the archive your friend Maya sent before you unpack it. A check script tells you which parts are done.

## Before you start

You need a terminal (the Terminal app on a Mac, Ubuntu on Linux or in WSL on Windows), **bats** (the tool that runs the check), and **zip** and **unzip**. On a Mac, zip and unzip are already there. If `bats --version`, `zip --version` or `unzip -v` doesn't print a version yet, install what's missing:

```bash
sudo apt install bats zip unzip    # Ubuntu, and Ubuntu in WSL
brew install bats-core             # a Mac, with Homebrew
```

## What's here

- `trip/`: the trip folder: photos, a video, music, documents, a packing list and `from-maya.tar.gz`. This is where you work.
- `answers.txt`: the eight steps. Four of them have a numbered line for your answer; the other four are things to do in the trip folder.
- `check.bats`: checks your answers and the trip folder. You don't need to change it.

## Run it

Open a terminal in this folder (the one with `answers.txt` in it), then go into the trip folder and look around:

```bash
cd trip
ls
```

Open `answers.txt` in any text editor to write your answers, and save it after each one.

## Check your work

From this folder (not from inside `trip`):

```bash
bats check.bats
```

At first almost every check fails: that is expected. Each step you finish turns its check into a ✓. A failing check's message says which step it is and gives a hint.

## The rules

- Write each answer on its numbered line, after the `)`, like the example: `0) packing-list.txt`.
- Write folder and file names exactly as `ls` shows them.
- Make the link and the archives inside the trip folder, with the names `answers.txt` gives: `tickets`, `documents.tar.gz` and `photos.zip`.
- Unpack Maya's archive in the trip folder too, and don't move or rename the folders that are already there.

## Tips

- `du -sh *` lists the size of everything in a folder; `| sort -hr` puts the biggest first.
- `ln -s` takes the real folder first and the link's name second. `ls -l` shows where a link points.
- Read tar's letters aloud: `-czf` create, zip, file; `-tzf` list; `-xzf` extract. The `f` comes last, right before the archive's name.
- List an archive before you unpack it: `tar -tzf` for a `.tar.gz`, `unzip -l` for a `.zip`.

## Hand it in

When it works, push your solution to a public repo of your own on GitHub, then paste that repo's address into **Submit your exercise** on the lesson page at [ask-codey.com](https://www.ask-codey.com). That's what completes the lesson. The lesson page shows the Git commands, step by step.
