local C = require("everybody-wants-that-line.colors")
local S = require("everybody-wants-that-line.settings")
local CB = require("everybody-wants-that-line.components.buffer")
local CD = require("everybody-wants-that-line.components.diagnostics")
local CE = require("everybody-wants-that-line.components.elements")
local CG = require("everybody-wants-that-line.components.git")
local CP = require("everybody-wants-that-line.components.filepath")
local CQ = require("everybody-wants-that-line.components.qflist")
local UC = require("everybody-wants-that-line.utils.color")
local UU = require("everybody-wants-that-line.utils.util")

local M = {}

---Returns `text` with spacers on each side
---@param content string[] Table of strings
---@return string
function M.spaced_text(content)
	if type(content) ~= "table" then
		return ""
	end
	return CE.el.spacer .. table.concat(content) .. CE.el.spacer
end

---Returns styled text
---@param text string
---@return string
function M.title(text)
	return UC.highlight_text(text, C.group_names.fg_60_bold)
end

---Returns bold text
---@param text string
---@return string
function M.bold(text)
	return UC.highlight_text(text, C.group_names.fg_bold)
end

---Returns buffer
---@return string
function M.get_buffer()
	local buffer = ""
	if S.opt.buffer.show == true then
		local bufnr_item = CB.get_buf_nr(S.opt.buffer)
		buffer = CE.el.space .. CB.get_buffer_symbol(S.opt.buffer.prefix) .. bufnr_item.result .. CB.get_buf_modflag() .. CE.get_separator(S.opt.separator)
	end
	return buffer
end

---comment
---@param diagnostic_object diagnostic_object
---@param count_group_name string
---@param arrow_group_name string
---@param lnum_group_name string
---@return string
local function highlight_diagnostic(diagnostic_object, count_group_name, arrow_group_name, lnum_group_name)
	local row = vim.api.nvim_win_get_cursor(vim.fn.win_getid())[1]
	local arrow = CE.el.arrow_down
	if row > diagnostic_object.first_lnum then
		arrow = CE.el.arrow_up
	elseif row == diagnostic_object.first_lnum then
		arrow = CE.el.arrow_right
	end
	return table.concat({
		UC.highlight_text(tostring(diagnostic_object.count), count_group_name),
		UC.highlight_text(arrow, arrow_group_name),
		UC.highlight_text(tostring(diagnostic_object.first_lnum), lnum_group_name),
	})
end

---Returns diagnostics
---@return string
function M.get_diagnostics()
	local diagnostics = CD.get_diagnostics()
	local err, warn, hint, info = "0", "0", "0", "0"
	if diagnostics.error.count > 0 then
		err = highlight_diagnostic(
			diagnostics.error,
			C.group_names.fg_error_bold,
			C.group_names.fg_error_50,
			C.group_names.fg_error
		)
	end
	if diagnostics.warn.count > 0 then
		warn = highlight_diagnostic(
			diagnostics.warn,
			C.group_names.fg_warn_bold,
			C.group_names.fg_warn_50,
			C.group_names.fg_warn
		)
	end
	if diagnostics.hint.count > 0 then
		hint = highlight_diagnostic(
			diagnostics.hint,
			C.group_names.fg_hint_bold,
			C.group_names.fg_hint_50,
			C.group_names.fg_hint
		)
	end
	if diagnostics.info.count > 0 then
		info = highlight_diagnostic(
			diagnostics.info,
			C.group_names.fg_info_bold,
			C.group_names.fg_info_50,
			C.group_names.fg_info
		)
	end
	local comma_space = CE.get_comma() .. CE.el.space
	return err .. comma_space .. warn .. comma_space .. hint .. comma_space .. info .. CE.get_separator(S.opt.separator)
end

---Returns branch name
---@return string
function M.get_branch_name()
	local branch = ""
	if #CG.cache.branch ~= 0 then
		branch = CG.cache.branch .. CE.el.space
	end
	return branch
end

---Returns branch and git status
---@return string
function M.get_branch_status()
	local insertions = ""
	local deletions = ""
	if CG.cache.diff_info.insertions ~= 0 then
		insertions = UC.highlight_text(tostring(CG.cache.diff_info.insertions), C.group_names.fg_diff_add_bold)
		insertions = insertions .. CE.get_plus("50") .. CE.el.space
	end
	if CG.cache.diff_info.deletions ~= 0 then
		deletions = UC.highlight_text(tostring(CG.cache.diff_info.deletions), C.group_names.fg_diff_delete_bold)
		deletions = deletions .. CE.get_minus("50") .. CE.el.space
	end
	return insertions .. deletions
end

---Returns path to the file
---@return string
function M.get_filepath()
	local path_parts = CP.get_filepath()
	local path = "[No name]"
	if #path_parts.relative.path ~= 0 and #path_parts.full.path ~= 0 then
		local filename = M.bold(path_parts.relative.filename)
		if S.opt.filepath.path == "tail" then
			path = filename
		elseif S.opt.filepath.path == "relative" then
			local relative = S.opt.filepath.shorten and path_parts.relative.shorten or path_parts.relative.path
			path = UC.highlight_text(relative, C.group_names.fg_60) .. filename
		elseif S.opt.filepath.path == "full" then
			local full = S.opt.filepath.shorten and path_parts.full.shorten or path_parts.full.path
			path = UC.highlight_text(full, C.group_names.fg_60) .. filename
		end
	end
	return CE.el.truncate .. path
end

---Returns netrw directory
---@param name string
---@return string
function M.get_treedir(name)
	local prog = M.title(name)
	---@type string
	local dir = vim.api.nvim_buf_get_name(0)
	return M.spaced_text({ prog, CE.el.space, dir })
end

---Returns quickfix list
---@return string
function M.get_quickfix()
	local idx = M.bold(tostring(CQ.get_qflist_idx()))
	local entries_count = CQ.get_entries_count()
	local files_count = CQ.get_files_w_entries_count()
	local title
	local quickfix = ""
	if tonumber(CQ.get_qflist_winid()) == tonumber(vim.api.nvim_get_current_win()) then
		local text_in = UC.highlight_text("in", C.group_names.fg_60)
		local text_file = UC.highlight_text(files_count > 1 and "files" or "file", C.group_names.fg_60)
		title = M.title("Quickfix List")
		local text_of = UC.highlight_text("of", C.group_names.fg_60)
		quickfix = M.spaced_text({
			title .. CE.el.space,
			idx .. CE.el.space .. text_of .. CE.el.space .. entries_count .. CE.el.space,
			files_count ~= 0 and text_in .. CE.el.space .. files_count .. CE.el.space .. text_file or "",
		})
	else
		if UU.laststatus() == 3 and not CQ.is_qflist_empty() then
			title = UC.highlight_text("QF:", C.group_names.fg_60)
			local text_slash = UC.highlight_text("/", C.group_names.fg_60)
			quickfix = table.concat({
				title .. CE.el.space,
				idx .. text_slash .. entries_count,
				CE.get_separator(S.opt.separator),
			})
		end
	end
	return quickfix
end

---Returns help filename
---@return string
function M.get_help()
	local help = M.title("Help")
	---@type string
	local buff_name = vim.api.nvim_buf_get_name(0)
	return M.spaced_text({
		help,
		CE.el.space,
		buff_name:match("[%s%w_]-%.%w-$")
	})
end

---Returns file size
---@return string
function M.get_filesize()
	local size
	if S.opt.filesize.metric == "decimal" then
		size = UU.si_fsize()
	elseif S.opt.filesize.metric == "binary" then
		size = UU.bi_fsize()
	end
	return CE.get_separator(S.opt.separator) .. size.size .. UC.highlight_text(size.postfix, C.group_names.fg_50)
end

---Returns ruller
---@param show_ln boolean
---@param show_col boolean
---@param show_loc boolean
---@return string
function M.get_ruller(show_ln, show_col, show_loc)
	return table.concat({
		CE.get_separator(S.opt.separator),
		show_ln and CE.get_ln() .. CE.get_comma() .. CE.el.space or "",
		show_col and CE.get_col() .. CE.get_comma() .. CE.el.space or "",
		show_loc and CE.get_loc() or "",
	})
end

---Helper. Creates auto command
---@param events string[]
---@param group string
---@param callback function
local function create_autocmd(events, group, callback)
	vim.api.nvim_create_autocmd(events, {
		pattern = "*",
		callback = callback,
		group = group,
	})
end

---Helper. Creates user auto command
---@param event string
---@param group string
---@param callback function
local function create_user_autocmd(event, group, callback)
	vim.api.nvim_create_autocmd('User', {
		pattern = event,
		callback = callback,
		group = group,
	})
end

---Sets auto commands
---@param cb function
local function setup_autocmd(cb)
	---@type string
	local autocmd_group = vim.api.nvim_create_augroup(UU.prefix .. "Group", { clear = true })

	-- colors
	create_autocmd({ "ColorScheme" }, autocmd_group, function()
		C.init()
		cb()
	end)

	-- buffer number
	-- buffer modified flag
	-- diagnostics
	create_autocmd({
		"BufAdd",
		"BufModifiedSet",
		"DiagnosticChanged",
		"CursorMoved",
	}, autocmd_group, function()
		cb()
	end)

	-- buffer number
	-- branch name
	create_autocmd({
		"BufEnter",
		"BufWinEnter"
	}, autocmd_group, function()
		CG.set_git_branch()
		CQ.set_qflist()
		cb()
	end)

	-- diff info
	create_autocmd({
		"BufWritePost",
		"BufReadPost"
	}, autocmd_group, function()
		CG.set_diff_info()
		cb()
	end)

	-- branch name
	-- diff info
	create_autocmd({
		"VimEnter",
		"FocusGained"
	}, autocmd_group, function()
		CG.set_git_branch()
		CG.set_diff_info()
		cb()
	end)

	-- quickfix list
	create_autocmd({
		"QuickFixCmdPost"
	}, autocmd_group, function()
		CQ.set_qflist()
		cb()
	end)

	-- neogit commit complete
	create_user_autocmd("NeogitCommitComplete", autocmd_group, function()
		CG.set_diff_info()
		cb()
	end)

	-- neogit push complete
	create_user_autocmd("NeogitPushComplete", autocmd_group, function()
		CG.set_diff_info()
		cb()
	end)
end

---Init controller
---@param opts opts
---@param cb function
function M.init(opts, cb)
	S.setup(opts)
	C.init()
	setup_autocmd(cb)
	cb()
end

return M
