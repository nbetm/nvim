-- Nord Deep — an arctic, north-bluish color palette taken to deeper depths.
-- Hand-rolled from the Helix theme of the same name. See:
-- - .notes/nord-deep.md                      (palette spec)
-- - .notes/helix/themes/nord-deep.toml       (1:1 source)
--
-- Activate with `:colorscheme nord-deep`.
-- Toggle transparent background by setting `vim.g.nord_deep_transparent = 1`
-- before loading (e.g. in init.lua before `colorscheme nord-deep`).

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end

local hl = function(name, opts) vim.api.nvim_set_hl(0, name, opts) end

-- Palette ------------------------------------------------------------------ {{{
local palette = {
  -- Polar Night
  base = "#212732",
  surface = "#2e3440",
  elevated = "#3b4252",
  subtle = "#434c5e",
  -- Snow Storm
  dim = "#798094",
  text = "#b8c5d1",
  bright = "#d4dce6",
  -- Frost
  aqua = "#8fbcbb",
  cyan = "#88c0d0",
  blue = "#81a1c1",
  navy = "#5e81ac",
  -- Aurora
  red = "#bf616a",
  orange = "#d08770",
  yellow = "#ebcb8b",
  green = "#a3be8c",
  magenta = "#b48ead",
  -- Derived
  cursorline = "#282e39",
  none = "NONE",
}

local p = palette
local transparent = vim.g.nord_deep_transparent
local bg = transparent and palette.none or palette.base
-- }}}

-- 1. Editor core ----------------------------------------------------------- {{{
hl("Normal", { fg = p.text, bg = bg })
hl("NormalNC", { fg = p.text, bg = bg })
hl("NormalFloat", { fg = p.text, bg = p.surface })
hl("EndOfBuffer", { fg = p.elevated, bg = transparent and p.none or nil })

hl("Cursor", { fg = p.base, bg = p.text })
hl("CursorIM", { fg = p.base, bg = p.text })
hl("lCursor", { fg = p.base, bg = p.text })
hl("CursorLine", { bg = p.cursorline })
hl("CursorColumn", { bg = p.cursorline })
hl("CursorLineNr", { fg = p.text, bg = p.cursorline })

hl("LineNr", { fg = p.subtle })
hl("LineNrAbove", { fg = p.subtle })
hl("LineNrBelow", { fg = p.subtle })

hl("SignColumn", { fg = p.subtle, bg = transparent and p.none or p.base })
hl("FoldColumn", { fg = p.subtle, bg = p.base })
hl("Folded", { fg = p.dim, bg = p.surface })

hl("Visual", { bg = p.elevated })
hl("VisualNOS", { bg = p.elevated })

hl("Pmenu", { fg = p.text, bg = p.surface })
hl("PmenuSel", { fg = p.cyan, bg = p.elevated })
hl("PmenuSbar", { bg = p.elevated })
hl("PmenuThumb", { bg = p.subtle })
hl("PmenuKind", { fg = p.aqua, bg = p.surface })
hl("PmenuKindSel", { fg = p.aqua, bg = p.elevated })
hl("PmenuExtra", { fg = p.dim, bg = p.surface })
hl("PmenuExtraSel", { fg = p.dim, bg = p.elevated })

hl("StatusLine", { fg = p.text, bg = p.elevated })
hl("StatusLineNC", { fg = p.dim, bg = p.surface })
hl("TabLine", { fg = p.dim, bg = p.surface })
hl("TabLineSel", { fg = p.text, bg = p.base })
hl("TabLineFill", { bg = p.surface })

hl("WinSeparator", { fg = p.elevated })
hl("VertSplit", { fg = p.elevated })
hl("WinBar", { fg = p.text, bg = p.surface })
hl("WinBarNC", { fg = p.dim, bg = p.surface })

hl("FloatBorder", { fg = p.subtle, bg = p.surface })
hl("FloatTitle", { fg = p.text, bg = p.surface, bold = true })
hl("FloatFooter", { fg = p.dim, bg = p.surface })

hl("ColorColumn", { bg = p.cursorline })
hl("Conceal", { fg = p.subtle })
hl("Directory", { fg = p.blue })
hl("Title", { fg = p.cyan, bold = true })
hl("MatchParen", { fg = p.orange, bold = true })

hl("NonText", { fg = p.elevated })
hl("SpecialKey", { fg = p.elevated })
hl("Whitespace", { fg = p.elevated })

hl("MsgArea", { fg = p.text })
hl("MoreMsg", { fg = p.cyan })
hl("ErrorMsg", { fg = p.red })
hl("WarningMsg", { fg = p.yellow })
hl("Question", { fg = p.cyan })
hl("MsgSeparator", { fg = p.dim, bg = p.surface })

hl("QuickFixLine", { bg = p.elevated })
hl("WildMenu", { fg = p.cyan, bg = p.elevated })

hl("Underlined", { underline = true })
hl("Bold", { bold = true })
hl("Italic", { italic = true })

-- Inlay hints
hl("LspInlayHint", { fg = p.dim, italic = true })
hl("LspSignatureActiveParameter", { fg = p.text, bg = p.elevated, bold = true })
hl("LspReferenceText", { bg = p.elevated })
hl("LspReferenceRead", { bg = p.elevated })
hl("LspReferenceWrite", { bg = p.elevated })
hl("LspCodeLens", { fg = p.dim, italic = true })
hl("LspCodeLensSeparator", { fg = p.elevated })

-- Terminal colors (maps to palette entries)
vim.g.terminal_color_0 = p.elevated -- color0  (black)
vim.g.terminal_color_1 = p.red -- color1  (red)
vim.g.terminal_color_2 = p.green -- color2  (green)
vim.g.terminal_color_3 = p.yellow -- color3  (yellow)
vim.g.terminal_color_4 = p.blue -- color4  (blue)
vim.g.terminal_color_5 = p.magenta -- color5  (magenta)
vim.g.terminal_color_6 = p.cyan -- color6  (cyan)
vim.g.terminal_color_7 = p.text -- color7  (white)
vim.g.terminal_color_8 = p.subtle -- color8  (bright black)
vim.g.terminal_color_9 = p.red -- color9  (bright red)
vim.g.terminal_color_10 = p.green -- color10 (bright green)
vim.g.terminal_color_11 = p.yellow -- color11 (bright yellow)
vim.g.terminal_color_12 = p.blue -- color12 (bright blue)
vim.g.terminal_color_13 = p.magenta -- color13 (bright magenta)
vim.g.terminal_color_14 = p.cyan -- color14 (bright cyan)
vim.g.terminal_color_15 = p.bright -- color15 (bright white)
-- }}}

-- 2. Search / spelling / diff ---------------------------------------------- {{{
hl("Search", { fg = p.base, bg = p.yellow })
hl("IncSearch", { fg = p.base, bg = p.cyan })
hl("CurSearch", { fg = p.base, bg = p.orange })
hl("Substitute", { fg = p.base, bg = p.red })

hl("SpellBad", { sp = p.red, undercurl = true })
hl("SpellCap", { sp = p.yellow, undercurl = true })
hl("SpellLocal", { sp = p.cyan, undercurl = true })
hl("SpellRare", { sp = p.navy, undercurl = true })

-- diff (buffer diff view)
hl("DiffAdd", { fg = p.green, bg = p.base })
hl("DiffDelete", { fg = p.red, bg = p.base })
hl("DiffChange", { fg = p.yellow, bg = p.base })
hl("DiffText", { fg = p.base, bg = p.yellow })

-- legacy diff syntax groups
hl("diffAdded", { fg = p.green })
hl("diffRemoved", { fg = p.red })
hl("diffChanged", { fg = p.yellow })
hl("diffFile", { fg = p.cyan })
hl("diffLine", { fg = p.dim })
hl("diffIndexLine", { fg = p.navy })
-- }}}

-- 3. Diagnostics ----------------------------------------------------------- {{{
-- Base diagnostic colors (fg only)
hl("DiagnosticError", { fg = p.red })
hl("DiagnosticWarn", { fg = p.yellow })
hl("DiagnosticInfo", { fg = p.navy })
hl("DiagnosticHint", { fg = p.navy })
hl("DiagnosticOk", { fg = p.green })

-- Virtual text (same colors, no bg)
hl("DiagnosticVirtualTextError", { fg = p.red })
hl("DiagnosticVirtualTextWarn", { fg = p.yellow })
hl("DiagnosticVirtualTextInfo", { fg = p.navy })
hl("DiagnosticVirtualTextHint", { fg = p.navy })
hl("DiagnosticVirtualTextOk", { fg = p.green })

-- Underline (undercurl with sp = color)
hl("DiagnosticUnderlineError", { sp = p.red, undercurl = true })
hl("DiagnosticUnderlineWarn", { sp = p.yellow, undercurl = true })
hl("DiagnosticUnderlineInfo", { sp = p.navy, undercurl = true })
hl("DiagnosticUnderlineHint", { sp = p.navy, undercurl = true })
hl("DiagnosticUnderlineOk", { sp = p.green, undercurl = true })

-- Signs (gutter)
hl("DiagnosticSignError", { fg = p.red })
hl("DiagnosticSignWarn", { fg = p.yellow })
hl("DiagnosticSignInfo", { fg = p.navy })
hl("DiagnosticSignHint", { fg = p.navy })
hl("DiagnosticSignOk", { fg = p.green })

-- Floating window
hl("DiagnosticFloatingError", { fg = p.red })
hl("DiagnosticFloatingWarn", { fg = p.yellow })
hl("DiagnosticFloatingInfo", { fg = p.navy })
hl("DiagnosticFloatingHint", { fg = p.navy })
hl("DiagnosticFloatingOk", { fg = p.green })

-- Special states
hl("DiagnosticDeprecated", { fg = p.dim, strikethrough = true })
hl("DiagnosticUnnecessary", { fg = p.dim })
-- }}}

-- 4. Syntax (Vim built-in groups) ------------------------------------------ {{{
hl("Comment", { fg = p.dim, italic = true })
hl("Constant", { fg = p.text })
hl("String", { fg = p.green })
hl("Character", { fg = p.yellow })
hl("Number", { fg = p.magenta })
hl("Float", { fg = p.magenta })
hl("Boolean", { fg = p.blue })

hl("Identifier", { fg = p.text })
hl("Function", { fg = p.cyan })

hl("Statement", { fg = p.blue })
hl("Conditional", { fg = p.blue })
hl("Repeat", { fg = p.blue })
hl("Label", { fg = p.blue })
hl("Operator", { fg = p.blue })
hl("Keyword", { fg = p.blue })
hl("Exception", { fg = p.blue })

hl("PreProc", { fg = p.blue })
hl("Include", { fg = p.blue })
hl("Define", { fg = p.blue })
hl("Macro", { fg = p.cyan })
hl("PreCondit", { fg = p.blue })

hl("Type", { fg = p.aqua })
hl("StorageClass", { fg = p.blue })
hl("Structure", { fg = p.aqua })
hl("Typedef", { fg = p.aqua })

hl("Special", { fg = p.cyan })
hl("SpecialChar", { fg = p.yellow })
hl("Tag", { fg = p.blue })
hl("Delimiter", { fg = p.text })
hl("SpecialComment", { fg = p.dim, italic = true })
hl("Debug", { fg = p.red })

hl("Ignore", { fg = p.dim })
hl("Error", { fg = p.red })
hl("Todo", { fg = p.base, bg = p.yellow, bold = true })
-- }}}

-- 5. Treesitter captures --------------------------------------------------- {{{

-- Comments
hl("@comment", { link = "Comment" })
hl("@comment.documentation", { link = "Comment" })
hl("@comment.error", { fg = p.red })
hl("@comment.warning", { fg = p.yellow })
hl("@comment.todo", { fg = p.base, bg = p.yellow, bold = true })
hl("@comment.note", { fg = p.base, bg = p.cyan, bold = true })

-- Strings
hl("@string", { link = "String" })
hl("@string.documentation", { fg = p.green, italic = true })
hl("@string.regexp", { fg = p.yellow })
hl("@string.escape", { fg = p.yellow })
hl("@string.special", { fg = p.green })
hl("@string.special.symbol", { fg = p.text })
hl("@string.special.path", { link = "Directory" })
hl("@string.special.url", { fg = p.cyan, underline = true })

-- Characters
hl("@character", { link = "Character" })
hl("@character.special", { fg = p.yellow })

-- Numbers / booleans
hl("@number", { link = "Number" })
hl("@number.float", { link = "Float" })
hl("@boolean", { link = "Boolean" })

-- Functions
hl("@function", { link = "Function" })
hl("@function.builtin", { fg = p.cyan })
hl("@function.call", { link = "Function" })
hl("@function.macro", { fg = p.cyan })
hl("@function.method", { link = "Function" })
hl("@function.method.call", { link = "Function" })

-- Variables
hl("@variable", { fg = p.text })
hl("@variable.builtin", { fg = p.text })
hl("@variable.parameter", { fg = p.text })
hl("@variable.member", { fg = p.aqua })

-- Types
hl("@type", { link = "Type" })
hl("@type.builtin", { fg = p.aqua })
hl("@type.definition", { fg = p.aqua })
hl("@type.qualifier", { fg = p.blue })

-- Constructors / attributes / properties
hl("@constructor", { fg = p.aqua })
hl("@attribute", { fg = p.text })
hl("@property", { fg = p.aqua })
hl("@field", { fg = p.aqua })

-- Constants
hl("@constant", { link = "Constant" })
hl("@constant.builtin", { fg = p.blue })
hl("@constant.macro", { link = "Macro" })

-- Keywords (no italic by design)
hl("@keyword", { link = "Keyword" })
hl("@keyword.control", { link = "Keyword" })
hl("@keyword.coroutine", { link = "Keyword" })
hl("@keyword.function", { link = "Keyword" })
hl("@keyword.operator", { link = "Keyword" })
hl("@keyword.return", { link = "Keyword" })
hl("@keyword.import", { fg = p.blue })
hl("@keyword.storage", { fg = p.blue })
hl("@keyword.repeat", { link = "Keyword" })
hl("@keyword.debug", { fg = p.cyan })
hl("@keyword.exception", { link = "Keyword" })
hl("@keyword.conditional", { link = "Keyword" })
hl("@keyword.conditional.ternary", { link = "Keyword" })
hl("@keyword.directive", { fg = p.blue })
hl("@keyword.directive.define", { fg = p.blue })

-- Operators / punctuation
hl("@operator", { link = "Operator" })
hl("@punctuation", { fg = p.text })
hl("@punctuation.delimiter", { fg = p.blue })
hl("@punctuation.bracket", { fg = p.blue })
hl("@punctuation.special", { fg = p.blue })

-- Labels / namespaces / modules
hl("@label", { link = "Label" })
hl("@namespace", { fg = p.text })
hl("@module", { fg = p.text })
hl("@module.builtin", { fg = p.text })

-- Tags (HTML/JSX)
hl("@tag", { fg = p.blue })
hl("@tag.builtin", { fg = p.blue })
hl("@tag.attribute", { fg = p.aqua })
hl("@tag.delimiter", { fg = p.blue })

-- Misc
hl("@define", { link = "Define" })
hl("@macro", { link = "Macro" })
hl("@include", { link = "Include" })
hl("@preproc", { link = "PreProc" })
hl("@debug", { link = "Debug" })
hl("@exception", { link = "Exception" })
hl("@conditional", { link = "Conditional" })
hl("@repeat", { link = "Repeat" })
hl("@storageclass", { link = "StorageClass" })
hl("@structure", { link = "Structure" })
hl("@symbol", { link = "Keyword" })
hl("@none", {})

-- Markup (Markdown / RST / etc.)
hl("@markup.heading", { fg = p.cyan, bold = true })
hl("@markup.heading.1", { fg = p.red, bold = true })
hl("@markup.heading.2", { fg = p.orange, bold = true })
hl("@markup.heading.3", { fg = p.yellow, bold = true })
hl("@markup.heading.4", { fg = p.green, bold = true })
hl("@markup.heading.5", { fg = p.cyan, bold = true })
hl("@markup.heading.6", { fg = p.blue, bold = true })

hl("@markup.heading.1.delimiter.vimdoc", { fg = p.elevated, bold = true })
hl("@markup.heading.2.delimiter.vimdoc", { fg = p.elevated, bold = true })
hl("@markup.heading.4.vimdoc", { link = "Title" })

hl("@markup.strong", { fg = p.text, bold = true })
hl("@markup.italic", { fg = p.text, italic = true })
hl("@markup.strikethrough", { fg = p.text, strikethrough = true })
hl("@markup.underline", { underline = true })

hl("@markup.link", { fg = p.cyan })
hl("@markup.link.label", { fg = p.cyan, underline = true })
hl("@markup.link.url", { fg = p.cyan, underline = true })

hl("@markup.list", { fg = p.text })
hl("@markup.list.checked", { fg = p.green })
hl("@markup.list.unchecked", { fg = p.subtle })

hl("@markup.quote", { fg = p.magenta })
hl("@markup.raw", { fg = p.aqua })
hl("@markup.raw.block", { fg = p.aqua })
hl("@markup.math", { fg = p.yellow })
hl("@markup.environment", { link = "@module" })

-- Diff annotations
hl("@diff.plus", { link = "diffAdded" })
hl("@diff.minus", { link = "diffRemoved" })
hl("@diff.delta", { link = "diffChanged" })

-- Legacy nvim-0.9 treesitter groups (kept for compatibility)
hl("@text.literal", { link = "Special" })
hl("@text.reference", { link = "Identifier" })
hl("@text.title", { link = "Title" })
hl("@text.uri", { link = "Underlined" })
hl("@text.todo", { link = "Todo" })
hl("@text.note", { link = "MoreMsg" })
hl("@text.warning", { link = "WarningMsg" })
hl("@text.danger", { link = "ErrorMsg" })
hl("@text.strong", { bold = true })
hl("@text.emphasis", { italic = true })
hl("@text.strike", { strikethrough = true })
hl("@text.underline", { link = "Underlined" })

hl("@method", { link = "Function" })
hl("@method.call", { link = "Function" })
hl("@parameter", { fg = p.text })
hl("@float", { link = "Float" })
-- }}}

-- 6. LSP semantic tokens --------------------------------------------------- {{{
hl("@lsp.type.class", { link = "@structure" })
hl("@lsp.type.decorator", { link = "@function" })
hl("@lsp.type.enum", { link = "@type" })
hl("@lsp.type.enumMember", { link = "@constant" })
hl("@lsp.type.function", { link = "@function" })
hl("@lsp.type.interface", { link = "@type" })
hl("@lsp.type.macro", { link = "@macro" })
hl("@lsp.type.method", { link = "@method" })
hl("@lsp.type.namespace", { link = "@namespace" })
hl("@lsp.type.parameter", { link = "@parameter" })
hl("@lsp.type.property", { link = "@property" })
hl("@lsp.type.struct", { link = "@structure" })
hl("@lsp.type.type", { link = "@type" })
hl("@lsp.type.typeParameter", { link = "@type.definition" })
hl("@lsp.type.variable", { link = "@variable" })

hl("@lsp.mod.deprecated", { strikethrough = true })
hl("@lsp.mod.readonly", {}) -- no change
hl("@lsp.mod.defaultLibrary", { link = "@constant.builtin" })
-- best-effort private member: italic fg
hl("@lsp.mod.private", { fg = p.text, italic = true })
-- }}}

-- 7. Markdown filetype groups (non-treesitter fallbacks) ------------------- {{{
hl("markdownH1", { link = "@markup.heading.1" })
hl("markdownH2", { link = "@markup.heading.2" })
hl("markdownH3", { link = "@markup.heading.3" })
hl("markdownH4", { link = "@markup.heading.4" })
hl("markdownH5", { link = "@markup.heading.5" })
hl("markdownH6", { link = "@markup.heading.6" })
hl("markdownUrl", { fg = p.cyan, underline = true })
hl("markdownCode", { fg = p.aqua })
hl("markdownCodeBlock", { fg = p.aqua })
hl("markdownBold", { fg = p.text, bold = true })
hl("markdownItalic", { fg = p.text, italic = true })
hl("markdownListMarker", { fg = p.text })
hl("markdownBlockquote", { fg = p.magenta })
-- }}}

-- 8. mini.nvim groups ------------------------------------------------------ {{{

-- mini.animate
hl("MiniAnimateCursor", { reverse = true, nocombine = true })
hl("MiniAnimateNormalFloat", { link = "NormalFloat" })

-- mini.clue
hl("MiniClueBorder", { link = "FloatBorder" })
hl("MiniClueDescGroup", { link = "DiagnosticFloatingWarn" })
hl("MiniClueDescSingle", { link = "NormalFloat" })
hl("MiniClueNextKey", { link = "DiagnosticFloatingHint" })
hl("MiniClueNextKeyWithPostkeys", { link = "DiagnosticFloatingError" })
hl("MiniClueSeparator", { link = "DiagnosticFloatingInfo" })
hl("MiniClueTitle", { link = "FloatTitle" })

-- mini.cmdline
hl("MiniCmdlinePeekBorder", { link = "FloatBorder" })
hl("MiniCmdlinePeekLineNr", { link = "DiagnosticSignWarn" })
hl("MiniCmdlinePeekNormal", { link = "NormalFloat" })
hl("MiniCmdlinePeekSep", { link = "SignColumn" })
hl("MiniCmdlinePeekSign", { link = "DiagnosticSignHint" })
hl("MiniCmdlinePeekTitle", { link = "FloatTitle" })

-- mini.completion
hl("MiniCompletionActiveParameter", { link = "LspSignatureActiveParameter" })
hl("MiniCompletionDeprecated", { link = "DiagnosticDeprecated" })
hl("MiniCompletionInfoBorderOutdated", { link = "DiagnosticFloatingWarn" })

-- mini.cursorword
hl("MiniCursorword", { underline = true })
hl("MiniCursorwordCurrent", { underline = true })

-- mini.deps (not installed but groups defined for completeness)
hl("MiniDepsChangeAdded", { link = "diffAdded" })
hl("MiniDepsChangeRemoved", { link = "diffRemoved" })
hl("MiniDepsHint", { link = "DiagnosticHint" })
hl("MiniDepsInfo", { link = "DiagnosticInfo" })
hl("MiniDepsMsgBreaking", { link = "DiagnosticWarn" })
hl("MiniDepsPlaceholder", { link = "Comment" })
hl("MiniDepsTitle", { link = "Title" })
hl("MiniDepsTitleError", { link = "DiffDelete" })
hl("MiniDepsTitleSame", { link = "DiffText" })
hl("MiniDepsTitleUpdate", { link = "DiffAdd" })

-- mini.diff
hl("MiniDiffSignAdd", { fg = p.green })
hl("MiniDiffSignChange", { fg = p.yellow })
hl("MiniDiffSignDelete", { fg = p.red })
hl("MiniDiffOverAdd", { link = "DiffAdd" })
hl("MiniDiffOverChange", { link = "DiffText" })
hl("MiniDiffOverChangeBuf", { link = "MiniDiffOverChange" })
hl("MiniDiffOverContext", { link = "DiffChange" })
hl("MiniDiffOverContextBuf", {})
hl("MiniDiffOverDelete", { link = "DiffDelete" })

-- mini.files
hl("MiniFilesBorder", { link = "FloatBorder" })
hl("MiniFilesBorderModified", { link = "DiagnosticFloatingWarn" })
hl("MiniFilesCursorLine", { link = "MiniPickMatchCurrent" })
hl("MiniFilesDirectory", { link = "Directory" })
hl("MiniFilesFile", { fg = p.text })
hl("MiniFilesNormal", { link = "NormalFloat" })
hl("MiniFilesTitle", { link = "FloatTitle" })
hl("MiniFilesTitleFocused", { fg = p.text, bg = p.elevated, bold = true })

-- mini.hipatterns (FIXME=red, HACK=orange, TODO=yellow, NOTE=cyan)
hl("MiniHipatternsFixme", { fg = p.base, bg = p.red, bold = true })
hl("MiniHipatternsHack", { fg = p.base, bg = p.orange, bold = true })
hl("MiniHipatternsTodo", { fg = p.base, bg = p.yellow, bold = true })
hl("MiniHipatternsNote", { fg = p.base, bg = p.cyan, bold = true })

-- mini.icons (link to closest named palette color)
hl("MiniIconsAzure", { fg = p.cyan }) -- closest "azure" is cyan in this palette
hl("MiniIconsBlue", { fg = p.blue })
hl("MiniIconsCyan", { fg = p.cyan })
hl("MiniIconsGreen", { fg = p.green })
hl("MiniIconsGrey", { fg = p.dim })
hl("MiniIconsOrange", { fg = p.orange })
hl("MiniIconsPurple", { fg = p.magenta }) -- closest purple is magenta
hl("MiniIconsRed", { fg = p.red })
hl("MiniIconsYellow", { fg = p.yellow })

-- mini.indentscope (matches Helix `ui.virtual.indent-guide` — subtle, blends in)
hl("MiniIndentscopeSymbol", { fg = p.elevated })
hl("MiniIndentscopeSymbolOff", { fg = p.red })

-- mini.jump
hl("MiniJump", { sp = p.cyan, undercurl = true })

-- mini.jump2d
hl("MiniJump2dDim", { fg = p.elevated })
hl("MiniJump2dSpot", { fg = p.base, bg = p.bright, bold = true, nocombine = true })
hl("MiniJump2dSpotAhead", { fg = p.base, bg = p.text, nocombine = true })
hl("MiniJump2dSpotUnique", { link = "MiniJump2dSpot" })

-- mini.map
hl("MiniMapNormal", { fg = p.dim, bg = p.elevated })
hl("MiniMapSymbolCount", { fg = p.dim })
hl("MiniMapSymbolLine", { fg = p.cyan })
hl("MiniMapSymbolView", { fg = p.cyan })

-- mini.notify
hl("MiniNotifyBorder", { link = "FloatBorder" })
hl("MiniNotifyLspProgress", { link = "MiniNotifyNormal" })
hl("MiniNotifyNormal", { link = "NormalFloat" })
hl("MiniNotifyTitle", { link = "FloatTitle" })

-- mini.operators
hl("MiniOperatorsExchangeFrom", { link = "IncSearch" })

-- mini.pick
hl("MiniPickBorder", { link = "FloatBorder" })
hl("MiniPickBorderBusy", { link = "DiagnosticFloatingWarn" })
hl("MiniPickBorderText", { link = "FloatTitle" })
hl("MiniPickCursor", { blend = 100, nocombine = true })
hl("MiniPickIconDirectory", { link = "Directory" })
hl("MiniPickIconFile", { link = "MiniPickNormal" })
hl("MiniPickHeader", { link = "DiagnosticFloatingHint" })
-- Three-tier hierarchy on row highlights:
--   Current = subtle (brightest, easy to track),
--   Marked  = elevated (medium, distinct),
--   Default = no bg.
hl("MiniPickMatchCurrent", { fg = p.cyan, bg = p.subtle })
hl("MiniPickMatchMarked", { bg = p.elevated })
hl("MiniPickMatchRanges", { link = "DiagnosticFloatingHint" })
hl("MiniPickNormal", { link = "NormalFloat" })
hl("MiniPickPreviewLine", { link = "CursorLine" })
hl("MiniPickPreviewRegion", { link = "IncSearch" })
hl("MiniPickPrompt", { link = "MiniPickMatchRanges" })
hl("MiniPickPromptCaret", { link = "DiagnosticFloatingInfo" })
hl("MiniPickPromptPrefix", { link = "DiagnosticFloatingInfo" })

-- mini.snippets
hl("MiniSnippetsCurrent", { sp = p.yellow, underdouble = true })
hl("MiniSnippetsCurrentReplace", { sp = p.red, underdouble = true })
hl("MiniSnippetsFinal", { sp = p.green, underdouble = true })
hl("MiniSnippetsUnvisited", { sp = p.cyan, underdouble = true })
hl("MiniSnippetsVisited", { sp = p.blue, underdouble = true })

-- mini.starter
hl("MiniStarterCurrent", { link = "MiniStarterItem" })
hl("MiniStarterFooter", { link = "Comment" })
hl("MiniStarterHeader", { fg = p.cyan, bold = true })
hl("MiniStarterInactive", { link = "Comment" })
hl("MiniStarterItem", { link = "Normal" })
hl("MiniStarterItemBullet", { fg = p.dim })
hl("MiniStarterItemPrefix", { fg = p.yellow, bold = true })
hl("MiniStarterSection", { fg = p.magenta })
hl("MiniStarterQuery", { fg = p.green, bold = true })

-- mini.statusline (modes mirror Helix statusline colors)
-- Normal: nord-text bg, insert: nord-cyan bg, visual: nord-aqua bg
hl("MiniStatuslineModeNormal", { fg = p.base, bg = p.text, bold = true })
hl("MiniStatuslineModeInsert", { fg = p.base, bg = p.cyan, bold = true })
hl("MiniStatuslineModeVisual", { fg = p.base, bg = p.aqua, bold = true })
hl("MiniStatuslineModeReplace", { fg = p.base, bg = p.red, bold = true })
hl("MiniStatuslineModeCommand", { fg = p.base, bg = p.yellow, bold = true })
hl("MiniStatuslineModeOther", { fg = p.base, bg = p.navy, bold = true })
hl("MiniStatuslineDevinfo", { fg = p.text, bg = p.elevated })
hl("MiniStatuslineFilename", { fg = p.text, bg = p.surface })
hl("MiniStatuslineFileinfo", { link = "MiniStatuslineDevinfo" })
hl("MiniStatuslineInactive", { link = "StatusLineNC" })

-- mini.surround
hl("MiniSurround", { link = "IncSearch" })

-- mini.tabline (bufferline — mirrors Helix bufferline: inactive on surface, active on base)
hl("MiniTablineCurrent", { fg = p.text, bg = p.base, bold = true })
hl("MiniTablineVisible", { fg = p.dim, bg = p.surface, bold = true })
hl("MiniTablineHidden", { fg = p.dim, bg = p.surface })
hl("MiniTablineModifiedCurrent", { fg = p.base, bg = p.cyan, bold = true })
hl("MiniTablineModifiedVisible", { fg = p.surface, bg = p.dim, bold = true })
hl("MiniTablineModifiedHidden", { fg = p.surface, bg = p.dim })
hl("MiniTablineFill", { link = "MiniTablineHidden" })
hl("MiniTablineTabpagesection", { fg = p.base, bg = p.green, bold = true })
hl("MiniTablineTrunc", { fg = p.cyan, bg = p.surface, bold = true })

-- mini.test
hl("MiniTestEmphasis", { bold = true })
hl("MiniTestFail", { fg = p.red, bold = true })
hl("MiniTestPass", { fg = p.green, bold = true })

-- mini.trailspace
hl("MiniTrailspace", { bg = p.red })
-- }}}

-- 9. Misc / link aliases --------------------------------------------------- {{{

-- Virtual text helpers (inlay hints follow Helix ui.virtual.inlay-hint style)
hl("NonText", { fg = p.elevated }) -- already set above — kept for clarity
hl("Conceal", { fg = p.subtle }) -- ditto

-- Quickfix
hl("qfLineNr", { fg = p.subtle })
hl("qfFileName", { fg = p.blue })

-- Nvim built-in float popup title conventions
hl("NvimInternalError", { fg = p.red })

-- Neovim health check
hl("healthError", { fg = p.red })
hl("healthWarning", { fg = p.yellow })
hl("healthSuccess", { fg = p.green })
-- }}}

-- Set colors_name LAST (signals successful load to Neovim)
vim.g.colors_name = "nord-deep"

-- Helix scopes without direct nvim equivalents (skipped):
-- ui.background.separator      — no standard nvim group; FloatBorder covers the use-case
-- ui.cursor.primary.normal/insert/select — nvim doesn't split Cursor by mode in highlight groups
-- ui.cursor.normal/insert/select         — same reason
-- ui.cursorcolumn.primary/secondary      — maps to CursorColumn (single group)
-- ui.highlight                           — maps to Visual/CurSearch; no distinct Helix concept needed
-- ui.picker.header / header.column / header.column.active  — mini.pick uses FloatTitle / DiagnosticFloatingHint
-- ui.statusline.separator                — no nvim equivalent; WinSeparator used for window borders
-- ui.text.info / ui.text.focus           — covered by Normal / NormalFloat / CursorLine
-- ui.virtual.wrap                        — no nvim equivalent (no wrap-guide highlight group)
-- diagnostic.error/warning/info/hint as top-level (non-underline) — translated to DiagnosticSign* / DiagnosticVirtualText*
-- string.special (Helix = green like string) — @string.special uses green above
-- type.enum.variant / type.parameter    — both map to @type (aqua)
-- function.special / function.method.private — covered by @function / @lsp.mod.private
-- keyword.storage                       — mapped to @keyword.storage
-- keyword.directive                     — mapped to @keyword.directive
