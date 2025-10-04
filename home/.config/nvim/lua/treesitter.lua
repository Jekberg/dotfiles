local paths = {
    '/usr/lib64'
}

local treesitter_configs = {
    rust   = { 'libtree-sitter-rust.so' },
    python = { 'libtree-sitter-python.so' },
}

local function try_parser(lang, path)
    local status, _ = pcall(function ()
        vim.treesitter.language.add(lang, { path = path })
    end)
    return not status
end

local function load_parser(lang)
    if vim.treesitter.language.add(lang) then
        -- No need to do anything
        return true
    end

    local parsers = treesitter_configs[lang]
    if parsers then
        -- Try to find a parser, this is a last ditch effort
        for _, parser in pairs(parsers) do
            for _, path in pairs(paths) do
                local parser_path = path .. '/' .. parser
                if try_parser(lang, parser_path) then
                    -- Sanity check that we found a parser
                    return vim.treesitter.language.add(lang)
                end
            end
        end
    end

    -- Maybe we can guess the parser name?
    for _, path in pairs(paths) do
        local parser_path = path .. '/libtree-sitter-' .. lang .. '.so'
        if try_parser(lang, parser_path) then
            return vim.treesitter.language.add(lang)
        end
    end

    -- Just in case, we shoud expect no parser if we reach this point
    return vim.treesitter.language.add(lang)
end

vim.api.nvim_create_autocmd('FileType', {
    desc = 'Tree Sitter autocmd',
    callback = function (args)
        if load_parser(args.match) then
            vim.treesitter.start(args.buf)
        end
    end
})

--[[
  Set folding automatically based on treesitte.

  TODO: It would be nice to rank the folding in order of preference e.g.

  1. LSP
  2. Tree Sitter
  3. Indent

  Or have a per language ranking.
--]]

vim.opt.foldenable = false
vim.opt.foldcolumn = '0'
vim.opt.foldlevel  = 10
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr   = 'v:lua.vim.treesitter.foldexpr()'
