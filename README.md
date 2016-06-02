## Contains script for downloading all necessary components to
## a new raspbian image

Plus probably host versions of DownloadPsychtoolbox and co, in case they go missing.

A few observations so far:

- Requires over 8gb of space (16 at least), I've currently maxed out the Debian VM without yet installing Octave.
- Data can be sent using system calls (don't need to worry about windows compat).
- Automatically run at boot, or wait for interaction?
- After PTB is out of beta Raspberry Pi support, fix the version in `ModifiedDownloadPsychtoolbox.m`
