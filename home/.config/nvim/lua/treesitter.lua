local paths = {
    '/usr/lib64'
}

local treesitter_configs = {
    rust = { 'libtree-sitter-rust.so' }
}

local function load_parser(name)
    if vim.treesitter.language.add(name) then
        -- No need to do anything
        return true
    end

    if not treesitter_configs[name] then
        -- The language is not supported
        return false
    end

    -- Try to find a parser, this is a last ditch effort
    for _, parser in pairs(treesitter_configs[name]) do
        for _, path in pairs(paths) do
            local parser_path = path .. '/' .. parser
            local status, _ = pcall(function ()
                vim.treesitter.language.add(name, { path = parser_path })
            end)

            if not status then
                -- Sanity check that we found a parser
                return vim.treesitter.language.add(name)
            end
        end
    end

    -- Just in case, we shoud expect no parser if we reach this point
    return vim.treesitter.language.add(name)
end

vim.api.nvim_create_autocmd('FileType', {
    desc = 'Tree Sitter autocmd',
    callback = function (args)
        if load_parser(args.match) then
            vim.treesitter.start(args.buf)
        end
    end
})

