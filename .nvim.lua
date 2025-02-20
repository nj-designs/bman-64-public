local opt = vim.opt
local autocmd = vim.api.nvim_create_autocmd

autocmd({ "BufRead" }, { pattern = { "*.asm" }, command = "set filetype=kickass" })

-- opt.expandtab = true
-- opt.tabstop = 8
-- opt.softtabstop = 8
-- opt.shiftwidth = 8
