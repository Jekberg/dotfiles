local catppuccin = {
    rosewater = '#F5E0DC',
    flamingo  = '#F2CDCD',
    pink      = '#F5C2E7',
    mauve     = '#CBA6F7',
    red       = '#F38BA8',
    maroon    = '#EBA0AC',
    peach     = '#FAB387',
    yellow    = '#F9E2AF',
    green     = '#A6E3A1',
    teal      = '#94E2D5',
    sky       = '#89DCEB',
    sapphire  = '#74C7EC',
    blue      = '#89B4FA',
    lavender  = '#B4BEFE',
    text      = '#CDD6F4',
    subtext1  = '#bac2de',
    subtext0  = '#A6ADC8',
    overlay2  = '#9399B2',
    overlay1  = '#7F849C',
    overlay0  = '#6C7086',
    surface2  = '#585B70',
    surface1  = '#45475A',
    surface0  = '#313244',
    base      = '#1E1E2E',
    mantle    = '#181825',
    crust     = '#11111B'
}

local scheme = {
    inactive_border = { fg = catppuccin.overlay0 },

    success         = { fg = catppuccin.green },
    warning         = { fg = catppuccin.yellow },
    error           = { fg = catppuccin.red },

    linenr          = { fg = catppuccin.overlay1 },
    active_linenr   = { fg = catppuccin.lavender },

    search          = { fg = catppuccin.surface0, bg = catppuccin.teal },
    active_search   = { fg = catppuccin.surface0, bg = catppuccin.teal },

    attributes      = { fg = catppuccin.yellow },
    braces          = { fg = catppuccin.overlay2 },
    builtin         = { fg = catppuccin.red },
    comments        = { fg = catppuccin.overlay2 },
    constants       = { fg = catppuccin.peach },
    delimiter       = { fg = catppuccin.overlay2 },
    escape          = { fg = catppuccin.pink },
    functions       = { fg = catppuccin.blue },
    keyword         = { fg = catppuccin.mauve },
    macros          = { fg = catppuccin.rosewater },
    numbers         = { fg = catppuccin.peach },
    operators       = { fg = catppuccin.sky },
    parameters      = { fg = catppuccin.maroon },
    property        = { fg = catppuccin.blue },
    strings         = { fg = catppuccin.green },
    symbols         = { fg = catppuccin.red },
    type            = { fg = catppuccin.yellow },

    link            = { fg = catppuccin.blue },
    heading1        = { fg = catppuccin.red },
    heading2        = { fg = catppuccin.peach },
    heading3        = { fg = catppuccin.yellow },
    heading4        = { fg = catppuccin.green },
    heading5        = { fg = catppuccin.sapphire },
    heading6        = { fg = catppuccin.lavender },
}

local highlighting = {
    -- General
    ['Normal']                 = { ctermbg = 'none', bg = 'none' },
    ['Visual']                 = { fg = catppuccin.rosewater, bg = catppuccin.overlay2},
    ['StatusLine']             = { fg = catppuccin.text, bg = catppuccin.surface2},
    ['WinSeparator']           = scheme.inactive_border,

    -- Search
    ['CurSearch']              = scheme.active_seach,
    ['Search']                 = scheme.seach,

    -- Line Numbers
    ['LineNr']                 = scheme.linenr,
    ['CursorLineNr']           = scheme.active_linenr,

    -- Messages
    ['OkMsg']                  = scheme.success,
    ['ErrMsg']                 = scheme.warning,
    ['WarningMsg']             = scheme.error,

    -- Treesitter and LSP
    ['@attribute']             = scheme.attributes,
    ['@attribute.builtin']     = scheme.builtin,
    ['@comment']               = scheme.comments,
    ['@constant']              = scheme.constants,
    ['@constant.builtin']      = scheme.builtin,
    ['@constant.macro']        = scheme.macro,
    ['@function']              = scheme.functions,
    ['@function.builtin']      = scheme.builtin,
    ['@function.macro']        = scheme.macro,
    ['@keyword']               = scheme.keyword,
    ['@module.builtin']        = scheme.builtin,
    ['@number']                = scheme.numbers,
    ['@operator']              = scheme.operators,
    ['@punctuation.delimiter'] = scheme.delimiter,
    ['@punctuation.bracket']   = scheme.braces,
    ['@property']              = scheme.property,
    ['@string']                = scheme.string,
    ['@string.escape']         = scheme.escape,
    ['@tag.builtin']           = scheme.builtin,
    ['@type']                  = scheme.type,
    ['@type.builtin']          = scheme.builtin,
    ['@variable']              = scheme.symbols,
    ['@variable.parameter']    = scheme.parameters,

    ['@markup.link']           = scheme.link,
    ['@markup.heading.1']      = scheme.heading1,
    ['@markup.heading.2']      = scheme.heading2,
    ['@markup.heading.3']      = scheme.heading3,
    ['@markup.heading.4']      = scheme.heading4,
    ['@markup.heading.5']      = scheme.heading5,
    ['@markup.heading.6']      = scheme.heading6,
}

for key, value in pairs(highlighting) do
    vim.api.nvim_set_hl(0, key, value)
end
