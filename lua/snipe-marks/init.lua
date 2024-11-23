local Menu = require("snipe.menu")

local M = {}

local get_current_marks = function()
	local bufnr = vim.api.nvim_get_current_buf()
	local marks = vim.fn.getmarklist(bufnr)

	if not marks or vim.tbl_isempty(marks) then
		vim.notify("No marks found", vim.log.levels.INFO)
		return {}
	end

	local items = {}
	for _, v in ipairs(marks) do
		local mark = string.sub(v.mark, 2, 3)
		local _, lnum, col, _ = unpack(v.pos)
		local name = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]

		table.insert(items, {
			mark = mark,
			lnum = lnum,
			col = col,
			name = name,
		})
	end
	return items
end

local format_mark_display = function(item)
	return string.format("%s %6d %4d %s", item.mark, item.lnum, item.col - 1, item.name)
end

local open_marks_menu = function(opts)
	local win = vim.api.nvim_get_current_win()
	local marks = get_current_marks()
	local menu = Menu:new({ position = opts.position, open_win_override = { title = "Local Marks" } })

	menu:add_new_buffer_callback(function(m)
		vim.keymap.set("n", opts.mappings.cancel, function()
			m:close()
		end, { nowait = true, buffer = m.buf })

		vim.keymap.set("n", opts.mappings.select, function()
			local hovered = m:hovered()
			local item = m.items[hovered]
			m:close()
			vim.api.nvim_win_set_cursor(win, { item.lnum, item.col - 1 })
		end, { nowait = true, buffer = m.buf })
	end)

	menu:open(marks, function(m, i)
		local item = marks[i]
		vim.api.nvim_win_set_cursor(win, { item.lnum, item.col - 1 })
		m:close()
	end, format_mark_display)
end

local default_config = {
	position = "cursor",
	mappings = {
		cancel = "<esc>",
		open = "<leader>m",
		select = "<cr>",
	},
}

M.setup = function(opts)
	local config = vim.tbl_deep_extend("keep", default_config, opts or {})
	vim.keymap.set("n", config.mappings.open, function()
		open_marks_menu(config)
	end, { desc = "Find local marks" })
end

return M
