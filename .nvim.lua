local compile_mode = vim.g.compile_mode or {}
compile_mode.default_command = "odin run ."
vim.g.compile_mode = compile_mode
