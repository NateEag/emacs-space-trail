# space-trail.el --- Remove trailing whitespace on save when sensible.

Copyright 2015 Nate Eagleson
* Author: Nate Eagleson <nate@nateeag.com>
* Keywords: whitespace, trailing whitespace
* Package-Requires: ((cl-lib "0.5"))
* Version: 0.1.0
* Homepage: http://github.com/NateEag/emacs-space-trail

# Commentary

To keep files clean and diffs readable, it's nice to strip trailing
whitespace on save.

To that end, Emacs has the built-in function `delete-trailing-whitespace`.
Alas, if you add it to `before-save-hook`, eventually, you will run into
problems.

Some file types can be damaged by stripping trailing whitespace. Patches,
for instance (imagine the pain of trying to figure out how two identical
lines could be marked as added and deleted - it me took a while to realize
what had happened).

Other file types, like Markdown, should have some trailing whitespace
stripped, but not all. Blank lines in code blocks should not have trailing
whitespace stripped.

space-trail teaches Emacs to handle those cases correctly.

It also provides extension points so you can teach space-trail to handle
cases it doesn't get right. When you find one, please file an issue or a PR.

# Basic Setup

To have space-trail handle trailing whitespace on save, put this elisp
somewhere in your Emacs config (like init.el):

    (space-trail-activate)

If you need to turn space-trail off temporarily, run
`M-x space-trail-deactivate`.

# Useful Variables

By default, space-trail does not strip whitespace from your current line.
You can change that by setting
`space-trail-strip-whitespace-on-current-line` to `t`.

`space-trail-ignored-modes` is a list of major-modes that should never have
trailing whitespace removed. It defaults to `'(diff-mode)`.

By default, space-trail will strip trailing whitespace inside programming
language strings. Set `space-trail-strip-whitespace-in-strings` to `nil` when
you want to suppress that behavior.

`space-trail-ignore-buffer` prevents whitespace stripping on a per-buffer
basis. It's a good thing to set in `.dir-locals.el` for projects that aren't
careful with trailing whitespace, so you don't add noise to diffs.

# Known Issues

space-trail does not have support for stripping trailing whitespace only on
modified lines. It really should.

Patches are greatly welcomed.

# License

This code is under the two-clause BSD license, which follows:

Copyright (c) 2015, Nate Eagleson
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

readme.md is generated from the source code using
[md-readme](https://github.com/thomas11/md-readme).



