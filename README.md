# Everybody wants that line
Minimalistic, informative and elegant statusline for neovim.

## Screenshots
### Examples
![screenshot](https://i.ibb.co/3ym5jsb/Group-14.png)

### What is what
![screenshot](https://i.ibb.co/GtLSRQg/Group-14-2.png)

## Features
- [x] Adaptive colors
- [x] Current buffer number and buffer modified flag
- [x] LSP diagnostics
- [x] Current git branch and git status (additions/deletions)
- [x] Current filename
- [x] Clean ruler
- [x] Support for NvimTree, Help, Packer, Fugitive
- [ ] Support for Quickfix List, Location List, Prompt
- [ ] Support for StatusLineNC (if multiple statuslines)

## Installation
### [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use "strash/everybody-wants-that-line.nvim"
```
### [vim-plug](https://github.com/junegunn/vim-plug)
```lua
Plug "strash/everybody-wants-that-line.nvim"
```

## Configuration
```lua
local that_line = require("everybody-wants-that-line")

that_line.setup({
	buffer = {
		symbol = "0",
		max_symbols = 5,
	},
	separator = "│",
})
```

## Contribution
If you found a bug please [open an issue](https://github.com/strash/everybody-wants-that-line.nvim/issues/new?assignees=&labels=bug&template=bug_report.md&title=) or [request a feature](https://github.com/strash/everybody-wants-that-line.nvim/issues/new?assignees=&labels=enhancement&template=feature_request.md&title=). All contributions are welcome! Just open a PR.

