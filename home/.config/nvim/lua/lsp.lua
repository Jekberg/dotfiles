-- Generic configuration common across every LSP
vim.lsp.config('*', {
    on_attach = function (client, bufnr)
        vim.lsp.completion.enable(true, client.id, bufnr, {
            autotrigger = true
        })
    end
})

local lsp_config = {
    clangd = {
        cmd = { 'clangd' },
        filetypes = { 'c','cc', 'cxx', 'cpp', 'h', 'hh', 'hxx', 'hpp' , 's'},
        root_markers = { '.clangd', 'compile_command.json' },
        capabilities = {
            textDocument = {
                semanticTokens = {
                    multilineTokenSupport = true,
                }
            }
        }
    },
    luals = {
        cmd = { 'lua-language-server' },
        filetypes = { 'lua' },
        root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
        settings = {
            Lua = {
                diagnostics = {
                    globals = { 'vim' },
                },
                runtime = {
                    version = 'LuaJIT',
                }
            }
        }
    },
    rust_analyzer = {
        cmd = { 'rust-analyzer' },
        filetypes = { 'rust' },
        root_markers = { 'Cargo.toml', 'Cargo.lock' }
    },
}

for k,v in pairs(lsp_config) do
    vim.lsp.config(k, v)
    vim.lsp.enable(k)
end
