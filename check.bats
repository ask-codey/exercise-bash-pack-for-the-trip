#!/usr/bin/env bats
# Checks your answers in answers.txt and the work you did in the trip folder.
# Run it from this folder with:  bats check.bats
# You don't need to change this file.

setup() {
  cd "$BATS_TEST_DIRNAME"
}

# The answer written after "N)" in answers.txt, without spaces or quotes at either end.
answer() {
  grep -E "^$1\)" answers.txt | head -n 1 | sed -E "s/^$1\)[[:space:]]*//; s/[[:space:]]+\$//; s/^[\"']//; s/[\"']\$//"
}

# The same, in lower case, without a / at the end, for answers where capitals don't matter.
plain() {
  answer "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's#/+$##'
}

# Fails with a message when question N has no answer yet.
need() {
  if [[ -z "$(answer "$1")" ]]; then
    echo "Question $1 has no answer yet. Write it after \"$1)\" in answers.txt."
    return 1
  fi
}

# The name of the biggest of the folders given, measured with du on this computer.
biggest() {
  du -sk "$@" | sort -n | tail -n 1 | cut -f2- | sed -E 's#/+$##; s#.*/##'
}

# Every file inside a folder, as a path that starts with the folder's own name, one per line.
files_in() {
  (cd trip && find "$1" -type f | sort)
}

# What an archive lists, one name per line, without a ./ in front.
listing() {
  sed -E 's#^\./##'
}

@test "the trip folder is still here" {
  if [[ ! -d trip/photos || ! -d trip/documents/bookings/2026/lisbon/tickets || ! -f trip/from-maya.tar.gz ]]; then
    echo "The trip folder, its photos, its documents/bookings/2026/lisbon/tickets folder or from-maya.tar.gz is missing. Download the exercise again to get it back."
    return 1
  fi
}

@test "1) the biggest folder in trip" {
  need 1
  want="$(biggest trip/photos trip/videos trip/music trip/documents)"
  if [[ "$(plain 1)" != "$want" ]]; then
    echo "Question 1: \"$(answer 1)\" isn't the biggest folder yet. In the trip folder, du -sh * lists the size of everything there, and | sort -hr puts the biggest first."
    return 1
  fi
}

@test "2) the biggest folder in photos" {
  need 2
  folders=()
  for f in trip/photos/*; do
    if [[ -d "$f" ]]; then folders+=("$f"); fi
  done
  want="$(biggest "${folders[@]}")"
  if [[ "$(plain 2)" != "$want" ]]; then
    echo "Question 2: \"$(answer 2)\" isn't the biggest folder in photos yet. The folder with the most photos isn't always the biggest: du -h photos lists each folder's size."
    return 1
  fi
}

@test "3) the df column for the room that's left" {
  need 3
  case "$(plain 3)" in
    avail|available) ;;
    *)
      echo "Question 3: \"$(answer 3)\" isn't the column that shows the room left yet. Run df -h . and read the header line, left to right."
      return 1
      ;;
  esac
}

@test "4) a link named tickets" {
  real="trip/documents/bookings/2026/lisbon/tickets"
  if [[ ! -d "$real" ]]; then
    echo "Task 4: the folder documents/bookings/2026/lisbon/tickets isn't where it was. Put it back: the link points to it, it doesn't replace it."
    return 1
  fi
  if [[ ! -L trip/tickets ]]; then
    if [[ -e trip/tickets ]]; then
      echo "Task 4: trip/tickets is there, but it isn't a link. In ls -l, a link's line starts with l. Make the link with ln -s."
    else
      echo "Task 4: there's no link named tickets in the trip folder yet. From the trip folder: ln -s, the real folder, then the link's name."
    fi
    return 1
  fi
  want="$(cd "$real" && pwd -P)"
  got="$(cd trip/tickets 2>/dev/null && pwd -P || true)"
  if [[ "$got" != "$want" ]]; then
    echo "Task 4: trip/tickets is a link, but it points to \"$(readlink trip/tickets)\", not to the tickets folder. Remove it with rm tickets (no / at the end) and make it again."
    return 1
  fi
  if [[ -L "$real/tickets" ]]; then
    echo "Task 4: the link works, but there's an extra link named tickets inside the real tickets folder, from running ln -s a second time. Remove it: rm documents/bookings/2026/lisbon/tickets/tickets"
    return 1
  fi
}

@test "5) the documents folder packed into documents.tar.gz" {
  f="trip/documents.tar.gz"
  if [[ ! -f "$f" ]]; then
    echo "Task 5: there's no documents.tar.gz in the trip folder yet. From the trip folder: tar -czf, the archive's name, then the folder to pack."
    return 1
  fi
  if ! gzip -t "$f" 2>/dev/null; then
    echo "Task 5: documents.tar.gz isn't zipped smaller with gzip. Make it again with the z in -czf."
    return 1
  fi
  inside="$(tar -tzf "$f" 2>/dev/null | listing)"
  while IFS= read -r name; do
    if ! grep -qxF "$name" <<< "$inside"; then
      echo "Task 5: documents.tar.gz doesn't hold $name. List it with tar -tzf: everything should sit inside one documents/ folder. Pack it again from the trip folder."
      return 1
    fi
  done < <(files_in documents)
}

@test "6) the photos folder packed into photos.zip" {
  f="trip/photos.zip"
  if ! command -v unzip > /dev/null; then
    echo "Task 6: this check needs unzip to look inside photos.zip. Install it first: sudo apt install unzip"
    return 1
  fi
  if [[ ! -f "$f" ]]; then
    echo "Task 6: there's no photos.zip in the trip folder yet. From the trip folder: zip -r, the archive's name, then the folder to pack."
    return 1
  fi
  if ! raw="$(unzip -Z1 "$f" 2>/dev/null)"; then
    echo "Task 6: unzip can't read photos.zip. Delete it and make it again with zip -r."
    return 1
  fi
  inside="$(listing <<< "$raw")"
  while IFS= read -r name; do
    if ! grep -qxF "$name" <<< "$inside"; then
      echo "Task 6: photos.zip doesn't hold $name. Without -r, zip packs only the folder's name, not what's in it. Check with unzip -l photos.zip."
      return 1
    fi
  done < <(files_in photos)
}

@test "7) the file in the maps folder of Maya's archive" {
  need 7
  want="$(tar -tzf trip/from-maya.tar.gz | listing | grep -E '/maps/[^/]+$' | head -n 1 | sed -E 's#.*/##')"
  if [[ "$(answer 7)" != "$want" ]]; then
    echo "Question 7: \"$(answer 7)\" isn't the file in the maps folder yet. tar -tzf lists an archive without unpacking it; names ending in / are folders."
    return 1
  fi
}

@test "8) Maya's archive unpacked in the trip folder" {
  while IFS= read -r name; do
    if [[ "$name" != */ && ! -f "trip/$name" ]]; then
      echo "Task 8: trip/$name isn't there yet. tar -xzf unpacks into the folder you're in, so run it from the trip folder."
      return 1
    fi
  done < <(tar -tzf trip/from-maya.tar.gz | listing)
}
