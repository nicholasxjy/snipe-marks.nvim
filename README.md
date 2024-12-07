# snipe-marks.nvim

Yet another marks navigate nvim plugin depends on [leath-dub/snipe.nvim](https://github.com/leath-dub/snipe.nvim)

## How to use

```lua

{
  "nicholasxjy/snipe-marks.nvim",
  dependencies = { "leath-dub/snipe.nvim" },
  opts = {
    position = "cursor",
    mappings = {
      open = "<leader>ml", -- local marks
      openAll = "<leader>mg", -- all marks
      cancel = "<esc>",
      select = "<cr>"
    }
  }
}
```

## Demo

![demo.gif](./assets/demo.gif)

# why not telescope?

Local marks is a good and quick way for me to navigate between code blocks when editing the current buffer.

The telescope UI is a bit distracted for me, snipe menu is so clean and simple.
