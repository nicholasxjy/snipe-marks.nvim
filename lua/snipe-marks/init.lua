local Menu = require("snipe.menu")

local M = {}

local get_marks = function(type)
	local bufnr = vim.api.nvim_get_current_buf()
	local local_marks = {
		items = vim.fn.getmarklist(bufnr),
		vim.fn.getmarklist(bufnr),
		mark_name = function(_, line)
			return vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
		end,
	}

	local global_marks = {
		items = vim.fn.getmarklist(),
		mark_name = function(mark, _)
			return vim.api.nvim_get_mark(mark, {})[4]
		end,
	}

	local all_marks = {}

	if type == "all" then
		all_marks = { local_marks, global_marks }
	else
		all_marks = { local_marks }
	end

	local marks_table = {}
	local marks_others = {}

	for _, v in ipairs(all_marks) do
		for _, m in ipairs(v.items) do
			local mark = string.sub(m.mark, 2, 3)
			local buf, lnum, col, _ = unpack(m.pos)
			local name = v.mark_name(mark, lnum)
			local line = string.format("%s %6d %4d %s", mark, lnum, col - 1, name)

			local row = {
				line = line,
				lnum = lnum,
				col = col,
				file = m.file or "",
				buf = buf,
			}
			-- non alphanumeric marks goes to last
			if mark:match("%w") then
				table.insert(marks_table, row)
			else
				table.insert(marks_others, row)
			end
		end
	end

	marks_table = vim.fn.extend(marks_table, marks_others)

	if not marks_table or vim.tbl_isempty(marks_table) then
		vim.notify("No marks found", vim.log.levels.INFO)
		return {}
	end
	return marks_table
end

local open_marks_menu = function(opts, type)
	local marks = get_marks(type)

	local menu = Menu:new({
		position = opts.position,
		open_win_override = { title = type == "all" and "All Marks" or "Local Marks" },
	})

	menu:add_new_buffer_callback(function(m)
		vim.keymap.set("n", opts.mappings.cancel, function()
			m:close()
		end, { nowait = true, buffer = m.buf })

		vim.keymap.set("n", opts.mappings.select, function()
			local hovered = m:hovered()
			local item = m.items[hovered]
			m:close()
			if item.file and item.file ~= "" then
				vim.cmd("edit " .. item.file)
			else
				vim.api.nvim_set_current_buf(item.buf)
			end
			local new_win = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_cursor(new_win, { item.lnum, item.col - 1 })
		end, { nowait = true, buffer = m.buf })
	end)

	menu:open(marks, function(m, i)
		local item = marks[i]
		local win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_cursor(win, { item.lnum, item.col - 1 })
		m:close()
	end, function(mark_item)
		return mark_item.line
	end)
end

local default_config = {
	position = "cursor",
	mappings = {
		cancel = "<esc>",
		open = "<leader>ml",
		openAll = "<leader>mg",
		select = "<cr>",
	},
}

M.setup = function(opts)
	local config = vim.tbl_deep_extend("keep", default_config, opts or {})

	vim.keymap.set("n", config.mappings.open, function()
		open_marks_menu(config)
	end, { desc = "Find local marks" })

	vim.keymap.set("n", config.mappings.openAll, function()
		open_marks_menu(config, "all")
	end, { desc = "Find all marks" })
end

return M
