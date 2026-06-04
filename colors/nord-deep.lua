-- Nord Deep — an arctic, north-bluish color palette taken to deeper depths.
-- See https://github.com/nbetm/nix-config/blob/main/docs/nord-deep.md for
-- the palette spec and design language.
--
-- Activate with `:colorscheme nord-deep`.
-- Toggle transparent background by setting `vim.g.nord_deep_transparent = 1`
-- before loading (e.g. in init.lua before `colorscheme nord-deep`).
--
-- Design language at a glance (full rationale in the doc linked above):
--
--   Polar Night (bg, dark → light)
--     bg   canvas, active tab
--     bg1  floats (all of them), inactive tabs/statusline
--     bg2  marked/current row, active statusline, Visual; ANSI 0
--     bg3  borders, separators, structural trim (no text role)
--
--   Washes  wash_<channel>  10% channel over bg — "this row is X" (diffs, errors, hits)
--   Deeps   deep_<channel>  saturated darks + fg_bright — pills / badges
--
--   Foregrounds
--     fg / fg_bright  body / emphasis; ANSI 7 / 15
--     grey0  ghost text, line numbers, fold cols, inline blame; ANSI 8
--     grey1  comments, disabled, unfocused titles
--     grey2  cursor line number, recessed-but-readable labels
--
--   Channels (role beyond syntax)
--     cyan     live cue (prompt prefix, picker matches, IncSearch)
--     orange   committed / paired (CurSearch, MatchParen, sticky keys)
--     yellow   passive attention (Search, warnings, DiffChange, escapes/regex)
--     green    strings, success
--     red      errors, deletions, FIXME
--     magenta  navigational landmark (headers, submenu entries)
--     blue     keywords, operators, punctuation, list bullets, action targets (key-hints, TODO)
--     navy     built-ins (booleans, nil/None), preprocessor/pragmas, secondary info (hints, NOTE)
--     aqua     type / structure noun (Type, @property, LSP kinds)
--
--   Rules
--     Floats sit on bg1; pickers/clue take a cyan title accent, others fg.
--     Tabline active tab sinks to bg; statusline active rises to bg2.
--     Selection changes bg only — fg falls through.
--     Severity (red / yellow / navy) reserved for actual attention.
--     Marked > Current row: both bg2, differ by bold + glyph.
--     Borders / separators sit at bg3.

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end

local hl = function(name, opts) vim.api.nvim_set_hl(0, name, opts) end

-- Alpha-composite two hex colors: `ratio` of `b` over `a`. Used to derive soft
-- overlays (e.g. cursorline) without baking magic hex into the palette.
-- Neovim hl groups don't honor alpha, so the result is precomputed here.
local blend = function(a, b, ratio)
  local ar, ag, ab = a:match("#(%x%x)(%x%x)(%x%x)")
  local br, bg_, bb = b:match("#(%x%x)(%x%x)(%x%x)")
  local mix = function(x, y) return math.floor(tonumber(x, 16) * (1 - ratio) + tonumber(y, 16) * ratio + 0.5) end
  return string.format("#%02x%02x%02x", mix(ar, br), mix(ag, bg_), mix(ab, bb))
end

-- Palette ------------------------------------------------------------------ {{{
-- Two sub-palettes: `palette1` for backgrounds, `palette2` for foregrounds.
local palette = {
  -- palette1: polar night (neutral surfaces)
  bg = "#212732",
  bg1 = "#2e3440",
  bg2 = "#3b4252",
  bg3 = "#434c5e",

  -- palette1: washes (channel-tinted row backgrounds, 10% channel over bg)
  wash_red = "#39313c",
  wash_orange = "#323138",
  wash_yellow = "#313439",
  wash_green = "#2d353a",
  wash_magenta = "#30313e",
  wash_blue = "#2b3340",
  wash_navy = "#2b3443",

  -- palette1: deeps (saturated pill backgrounds, paired with fg_bright)
  deep_red = "#82515b",
  deep_orange = "#785751",
  deep_yellow = "#665f50",
  deep_green = "#556356",
  deep_magenta = "#6a5a70",
  deep_blue = "#4e6075",
  deep_navy = "#4b617d",

  -- palette2: default / emphasis foregrounds
  fg = "#b8c5d1",
  fg_bright = "#d4dce6",

  -- palette2: greys (de-emphasis foregrounds)
  grey0 = "#5d6478",
  grey1 = "#798094",
  grey2 = "#929aae",

  -- palette2: frost (structural syntax) — navy brightened for contrast, rest as upstream Nord
  aqua = "#8fbcbb",
  cyan = "#88c0d0",
  blue = "#81a1c1",
  navy = "#6c8eb8",

  -- palette2: aurora (semantic syntax) — red brightened for contrast, rest as upstream Nord
  red = "#c97078",
  orange = "#d08770",
  yellow = "#ebcb8b",
  green = "#a3be8c",
  magenta = "#b48ead",

  none = "NONE",
}

-- Derived overlay.
-- Blend of bg and bg1 (the non-transparent fallback for the `#2e344080` recipe).
palette.cursorline = blend(palette.bg, palette.bg1, 0.5)

local p = palette
local transparent = vim.g.nord_deep_transparent
local bg = transparent and palette.none or palette.bg
-- }}}

-- 1. Editor core ----------------------------------------------------------- {{{
-- Base text + floats (all floats on bg1)
hl("Normal", { fg = p.fg, bg = bg })
hl("NormalNC", { fg = p.fg, bg = bg })
hl("NormalFloat", { fg = p.fg, bg = p.bg1 })
hl("EndOfBuffer", { fg = p.bg3, bg = transparent and p.none or nil })

-- Cursor
hl("Cursor", { fg = p.bg, bg = p.fg })
hl("CursorIM", { link = "Cursor" })
hl("lCursor", { link = "Cursor" })

-- Editor-buffer active line
hl("CursorLine", { bg = p.cursorline })
hl("CursorColumn", { bg = p.cursorline })
hl("CursorLineNr", { fg = p.grey2, bg = p.cursorline })

-- Line numbers sit at the ghost-text tier
hl("LineNr", { fg = p.grey0 })
hl("LineNrAbove", { fg = p.grey0 })
hl("LineNrBelow", { fg = p.grey0 })

-- Sign / fold columns sit on canvas
hl("SignColumn", { fg = p.bg3, bg = transparent and p.none or p.bg })
hl("FoldColumn", { fg = p.grey0, bg = p.bg })
hl("Folded", { fg = p.grey1, bg = p.bg1 })

-- Visual selection
hl("Visual", { bg = p.bg2 })
hl("VisualNOS", { bg = p.bg2 })

-- Pmenu (cmdline + LSP completion)
hl("Pmenu", { link = "NormalFloat" })
hl("PmenuBorder", { link = "FloatBorder" })
hl("PmenuSel", { bg = p.bg3 })
hl("PmenuMatch", { fg = p.cyan, bold = true })
hl("PmenuMatchSel", { fg = p.cyan, bold = true })
hl("PmenuSbar", { bg = p.bg2 })
hl("PmenuThumb", { bg = p.navy })
hl("PmenuKind", { fg = p.aqua, bg = p.bg1 })
hl("PmenuKindSel", { fg = p.aqua, bg = p.bg3 })
hl("PmenuExtra", { fg = p.grey1, bg = p.bg1 })
hl("PmenuExtraSel", { fg = p.grey2, bg = p.bg3 })

-- Status / tab strips
hl("StatusLine", { fg = p.fg, bg = p.bg1 })
hl("StatusLineNC", { fg = p.grey1, bg = p.bg1 })
hl("TabLine", { fg = p.grey1, bg = p.bg1 })
hl("TabLineSel", { fg = p.fg, bg = p.bg })
hl("TabLineFill", { bg = p.bg1 })

-- Window separators / vertical splits / WinBar
hl("WinSeparator", { fg = p.bg3 })
hl("VertSplit", { fg = p.bg3 })
hl("WinBar", { fg = p.fg, bg = p.bg1 })
hl("WinBarNC", { fg = p.grey1, bg = p.bg1 })

-- Float frame
hl("FloatBorder", { fg = p.bg3, bg = p.bg1 })
hl("FloatTitle", { fg = p.fg, bg = p.bg1, bold = true })
hl("FloatFooter", { fg = p.grey1, bg = p.bg1 })

-- Float / popup drop-shadow (only shown with shadow effects enabled). Dark
-- nord shadow via canvas bg + blend, instead of the default off-palette grey.
hl("FloatShadow", { bg = p.bg, blend = 80 })
hl("FloatShadowThrough", { bg = p.bg, blend = 100 })
hl("PmenuShadow", { link = "FloatShadow" })
hl("PmenuShadowThrough", { link = "FloatShadowThrough" })

hl("ColorColumn", { bg = p.cursorline })
hl("Conceal", { fg = p.bg3 })
hl("Directory", { fg = p.blue })
hl("Title", { fg = p.cyan, bold = true })
hl("MatchParen", { fg = p.orange, bold = true })

hl("NonText", { fg = p.bg3 })
hl("SpecialKey", { fg = p.bg3 })
hl("Whitespace", { fg = p.bg3 })

-- Messages / cmdline
hl("MsgArea", { fg = p.fg })
hl("ModeMsg", { fg = p.yellow })
hl("MoreMsg", { fg = p.cyan })
hl("ErrorMsg", { fg = p.red })
hl("WarningMsg", { fg = p.yellow })
hl("OkMsg", { fg = p.green })
hl("Question", { fg = p.cyan })
hl("MsgSeparator", { fg = p.bg3, bg = p.bg1 })

-- Quickfix current entry
-- QuickFixLine: qf is a normal window (over canvas), so bg2
-- WildMenu: shows in the pum (a float, over bg1), so bg3
hl("QuickFixLine", { fg = p.fg_bright, bg = p.bg2 })
hl("WildMenu", { bg = p.bg3 })

hl("Underlined", { underline = true })
hl("Bold", { bold = true })
hl("Italic", { italic = true })

-- Preinsert preview (ghost text about to be inserted) — autosuggest tier.
hl("PreInsert", { fg = p.grey0 })

-- Inlay hints / LSP reference bands
hl("LspInlayHint", { link = "Comment" })
hl("LspSignatureActiveParameter", { fg = p.fg, bg = p.bg3, bold = true })
hl("LspReferenceText", { bg = p.bg2 })
hl("LspReferenceRead", { bg = p.bg2 })
hl("LspReferenceWrite", { bg = p.bg2 })
hl("LspCodeLens", { link = "Comment" })
hl("LspCodeLensSeparator", { fg = p.bg3 })

-- ANSI colors
vim.g.terminal_color_0 = p.bg2
vim.g.terminal_color_1 = p.red
vim.g.terminal_color_2 = p.green
vim.g.terminal_color_3 = p.yellow
vim.g.terminal_color_4 = p.blue
vim.g.terminal_color_5 = p.magenta
vim.g.terminal_color_6 = p.cyan
vim.g.terminal_color_7 = p.fg
vim.g.terminal_color_8 = p.grey0
vim.g.terminal_color_9 = p.red
vim.g.terminal_color_10 = p.green
vim.g.terminal_color_11 = p.yellow
vim.g.terminal_color_12 = p.blue
vim.g.terminal_color_13 = p.magenta
vim.g.terminal_color_14 = p.cyan
vim.g.terminal_color_15 = p.fg_bright
-- }}}

-- 2. Search / spelling / diff ---------------------------------------------- {{{
-- Match-state trio at char level
hl("Search", { fg = p.bg, bg = p.yellow })
hl("IncSearch", { fg = p.bg, bg = p.cyan })
hl("CurSearch", { fg = p.bg, bg = p.orange })
hl("Substitute", { fg = p.bg, bg = p.red })

-- Spelling
hl("SpellBad", { sp = p.red, undercurl = true })
hl("SpellCap", { sp = p.yellow, undercurl = true })
hl("SpellLocal", { sp = p.cyan, undercurl = true })
hl("SpellRare", { sp = p.navy, undercurl = true })

-- Buffer diff view
hl("DiffAdd", { bg = p.wash_green })
hl("DiffDelete", { bg = p.wash_red })
hl("DiffChange", { bg = p.wash_yellow })
hl("DiffText", { fg = p.fg_bright, bg = p.deep_yellow })

-- Legacy diff syntax (when viewing a `.diff` / `.patch` file as text)
hl("diffAdded", { fg = p.green })
hl("diffRemoved", { fg = p.red })
hl("diffChanged", { fg = p.yellow })
hl("diffFile", { fg = p.cyan })
hl("diffLine", { fg = p.grey1 })
hl("diffIndexLine", { fg = p.navy })

-- Generic diff-state groups (gitsigns, vim.health, fugitive, etc.)
hl("Added", { link = "diffAdded" })
hl("Changed", { link = "diffChanged" })
hl("Removed", { link = "diffRemoved" })
-- }}}

-- 3. Diagnostics ----------------------------------------------------------- {{{
-- Severity ladder: red errors, yellow warnings, navy hints, navy info.
--
-- NOTE: The "diagnostic messages use washes, not coloured body fg" rule:
-- applying that here would mean DiagnosticFloating*/VirtualText* set wash bg
-- + neutral fg, but those hl groups colour the entire row including the
-- leading severity glyph — so the channel signal in the glyph would vanish.
-- Splitting glyph color from body color requires vim.diagnostic.config({
-- float, virtual_text }) work that wraps each diagnostic into multiple
-- highlight ranges. Base diagnostic colors (fg only)
hl("DiagnosticError", { fg = p.red })
hl("DiagnosticWarn", { fg = p.yellow })
hl("DiagnosticInfo", { fg = p.navy })
hl("DiagnosticHint", { fg = p.navy })
hl("DiagnosticOk", { fg = p.green })

-- Virtual text, signs (gutter), floating window (all share the base color per severity)
hl("DiagnosticVirtualTextError", { link = "DiagnosticError" })
hl("DiagnosticVirtualTextWarn", { link = "DiagnosticWarn" })
hl("DiagnosticVirtualTextInfo", { link = "DiagnosticInfo" })
hl("DiagnosticVirtualTextHint", { link = "DiagnosticHint" })
hl("DiagnosticVirtualTextOk", { link = "DiagnosticOk" })

hl("DiagnosticSignError", { link = "DiagnosticError" })
hl("DiagnosticSignWarn", { link = "DiagnosticWarn" })
hl("DiagnosticSignInfo", { link = "DiagnosticInfo" })
hl("DiagnosticSignHint", { link = "DiagnosticHint" })
hl("DiagnosticSignOk", { link = "DiagnosticOk" })

hl("DiagnosticFloatingError", { link = "DiagnosticError" })
hl("DiagnosticFloatingWarn", { link = "DiagnosticWarn" })
hl("DiagnosticFloatingInfo", { link = "DiagnosticInfo" })
hl("DiagnosticFloatingHint", { link = "DiagnosticHint" })
hl("DiagnosticFloatingOk", { link = "DiagnosticOk" })

-- Underline uses `sp` + `undercurl`
hl("DiagnosticUnderlineError", { sp = p.red, undercurl = true })
hl("DiagnosticUnderlineWarn", { sp = p.yellow, undercurl = true })
hl("DiagnosticUnderlineInfo", { sp = p.navy, undercurl = true })
hl("DiagnosticUnderlineHint", { sp = p.navy, undercurl = true })
hl("DiagnosticUnderlineOk", { sp = p.green, undercurl = true })

-- Special states
hl("DiagnosticDeprecated", { fg = p.grey1, strikethrough = true })
hl("DiagnosticUnnecessary", { fg = p.grey1 })
-- }}}

-- 4. Syntax (Vim built-in groups) ------------------------------------------ {{{
hl("Comment", { fg = p.grey1, italic = true })
hl("Constant", { fg = p.fg })
hl("String", { fg = p.green })
hl("Character", { fg = p.yellow })
hl("Number", { fg = p.magenta })
hl("Float", { fg = p.magenta })
hl("Boolean", { fg = p.navy })

hl("Identifier", { fg = p.fg })
hl("Function", { fg = p.cyan })

hl("Statement", { fg = p.blue })
hl("Conditional", { fg = p.blue })
hl("Repeat", { fg = p.blue })
hl("Label", { fg = p.blue })
hl("Operator", { fg = p.blue })
hl("Keyword", { fg = p.blue })
hl("Exception", { fg = p.blue })

hl("Macro", { fg = p.cyan })
hl("PreProc", { fg = p.navy })
hl("Include", { fg = p.navy })
hl("Define", { fg = p.navy })
hl("PreCondit", { fg = p.navy })

hl("Type", { fg = p.aqua })
hl("StorageClass", { fg = p.blue })
hl("Structure", { fg = p.aqua })
hl("Typedef", { fg = p.aqua })

hl("Special", { fg = p.cyan })
hl("SpecialChar", { fg = p.yellow })
hl("Tag", { fg = p.blue })
hl("Delimiter", { fg = p.fg })
hl("SpecialComment", { link = "Comment" })
hl("Debug", { fg = p.red })

hl("Ignore", { fg = p.grey1 })
hl("Error", { fg = p.red })
hl("Todo", { link = "@comment.todo" })
-- }}}

-- 5. Treesitter captures --------------------------------------------------- {{{
-- Comments
hl("@comment", { link = "Comment" })
hl("@comment.documentation", { link = "Comment" })
hl("@comment.error", { fg = p.red, bold = true }) -- FIXME
hl("@comment.warning", { fg = p.yellow, bold = true }) -- WARN
hl("@comment.todo", { fg = p.blue, bold = true }) -- TODO
hl("@comment.note", { fg = p.navy, bold = true }) -- NOTE

-- Strings
hl("@string", { link = "String" })
hl("@string.documentation", { fg = p.green, italic = true })
hl("@string.regexp", { fg = p.yellow })
hl("@string.escape", { fg = p.yellow })
hl("@string.special", { fg = p.green })
hl("@string.special.symbol", { fg = p.fg })
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
hl("@variable", { fg = p.fg })
hl("@variable.builtin", { fg = p.fg })
hl("@variable.parameter", { fg = p.fg })
hl("@variable.member", { fg = p.aqua })

-- Types
hl("@type", { link = "Type" })
hl("@type.builtin", { fg = p.aqua })
hl("@type.definition", { fg = p.aqua })
hl("@type.qualifier", { fg = p.blue })

-- Constructors / attributes / properties
hl("@constructor", { fg = p.aqua })
hl("@attribute", { fg = p.fg })
hl("@attribute.builtin", { fg = p.fg })
hl("@property", { fg = p.aqua })
hl("@field", { fg = p.aqua })

-- Constants
hl("@constant", { link = "Constant" })
hl("@constant.builtin", { fg = p.navy })
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
hl("@keyword.directive", { fg = p.navy })
hl("@keyword.directive.define", { fg = p.navy })

-- Operators / punctuation
hl("@operator", { link = "Operator" })
hl("@punctuation", { fg = p.fg })
hl("@punctuation.delimiter", { fg = p.blue })
hl("@punctuation.bracket", { fg = p.blue })
hl("@punctuation.special", { fg = p.blue })

-- Labels / namespaces / modules
hl("@label", { link = "Label" })
hl("@namespace", { fg = p.fg })
hl("@module", { fg = p.fg })
hl("@module.builtin", { fg = p.fg })

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
hl("@markup.heading", { fg = p.fg_bright, bold = true })
hl("@markup.heading.1", { fg = p.magenta, bold = true })
hl("@markup.heading.2", { fg = p.magenta, bold = true })
hl("@markup.heading.3", { fg = p.magenta, bold = true })
hl("@markup.heading.4", { fg = p.magenta, bold = true })
hl("@markup.heading.5", { fg = p.magenta, bold = true })
hl("@markup.heading.6", { fg = p.magenta, bold = true })

hl("@markup.heading.1.delimiter.vimdoc", { fg = p.bg3, bold = true })
hl("@markup.heading.2.delimiter.vimdoc", { fg = p.bg3, bold = true })
hl("@markup.heading.4.vimdoc", { link = "Title" })

hl("@markup.strong", { fg = p.fg, bold = true })
hl("@markup.italic", { fg = p.fg, italic = true })
hl("@markup.strikethrough", { fg = p.fg, strikethrough = true })
hl("@markup.underline", { underline = true })

hl("@markup.link", { fg = p.cyan })
hl("@markup.link.label", { fg = p.cyan, underline = true })
hl("@markup.link.url", { fg = p.cyan, underline = true })

-- List bullets (`-`, `*`, `+`, `1.`)
hl("@markup.list", { fg = p.blue })
hl("@markup.list.checked", { fg = p.green })
hl("@markup.list.unchecked", { fg = p.grey1 })

hl("@markup.quote", { fg = p.grey1, italic = true })
hl("@markup.raw", { fg = p.aqua })
hl("@markup.raw.block", { fg = p.aqua })
hl("@markup.math", { fg = p.yellow })
hl("@markup.environment", { link = "@module" })

-- Diff annotations
hl("@diff.plus", { link = "diffAdded" })
hl("@diff.minus", { link = "diffRemoved" })
hl("@diff.delta", { link = "diffChanged" })

-- Legacy nvim-0.9 treesitter groups — commented out as a safety net.
-- nvim-treesitter post-rewrite (the version we use) emits the modern
-- @markup.* / @comment.* / @function.method / @variable.parameter captures
-- instead. Uncomment if a stale query somewhere still fires legacy names.
-- hl("@text.literal", { link = "Special" })
-- hl("@text.reference", { link = "Identifier" })
-- hl("@text.title", { link = "Title" })
-- hl("@text.uri", { link = "Underlined" })
-- hl("@text.todo", { link = "Todo" })
-- hl("@text.note", { link = "MoreMsg" })
-- hl("@text.warning", { link = "WarningMsg" })
-- hl("@text.danger", { link = "ErrorMsg" })
-- hl("@text.strong", { bold = true })
-- hl("@text.emphasis", { italic = true })
-- hl("@text.strike", { strikethrough = true })
-- hl("@text.underline", { link = "Underlined" })
-- hl("@method", { link = "Function" })
-- hl("@method.call", { link = "Function" })
-- hl("@parameter", { fg = p.fg })
-- hl("@float", { link = "Float" })
-- }}}

-- 6. LSP semantic tokens --------------------------------------------------- {{{
hl("@lsp.type.class", { link = "@structure" })
hl("@lsp.type.decorator", { link = "@function" })
hl("@lsp.type.enum", { link = "@type" })
hl("@lsp.type.enumMember", { link = "@constant" })
hl("@lsp.type.function", { link = "@function" })
hl("@lsp.type.interface", { link = "@type" })
hl("@lsp.type.macro", { link = "@macro" })
hl("@lsp.type.method", { link = "@function.method" })
hl("@lsp.type.namespace", { link = "@namespace" })
hl("@lsp.type.parameter", { link = "@variable.parameter" })
hl("@lsp.type.property", { link = "@property" })
hl("@lsp.type.struct", { link = "@structure" })
hl("@lsp.type.type", { link = "@type" })
hl("@lsp.type.typeParameter", { link = "@type.definition" })
hl("@lsp.type.variable", { link = "@variable" })

hl("@lsp.mod.deprecated", { strikethrough = true })
hl("@lsp.mod.readonly", {})
hl("@lsp.mod.defaultLibrary", { link = "@constant.builtin" })
hl("@lsp.mod.private", { fg = p.fg, italic = true })
-- }}}

-- 7. Markdown filetype groups (non-treesitter fallbacks) ------------------- {{{
-- Mirror the @markup.* treatments from Section 5
hl("markdownH1", { link = "@markup.heading.1" })
hl("markdownH2", { link = "@markup.heading.2" })
hl("markdownH3", { link = "@markup.heading.3" })
hl("markdownH4", { link = "@markup.heading.4" })
hl("markdownH5", { link = "@markup.heading.5" })
hl("markdownH6", { link = "@markup.heading.6" })

hl("markdownBold", { link = "@markup.strong" })
hl("markdownItalic", { link = "@markup.italic" })

hl("markdownListMarker", { link = "@markup.list" })

hl("markdownUrl", { link = "@markup.link.url" })

hl("markdownCode", { link = "@markup.raw" })
hl("markdownCodeBlock", { link = "@markup.raw.block" })
hl("markdownBlockquote", { link = "@markup.quote" })
-- }}}

-- 8. mini.nvim groups ------------------------------------------------------ {{{
-- mini.animate
hl("MiniAnimateCursor", { reverse = true, nocombine = true })
hl("MiniAnimateNormalFloat", { link = "NormalFloat" })

-- mini.clue
hl("MiniClueBorder", { fg = p.bg3, bg = p.bg1 })
hl("MiniClueDescGroup", { fg = p.magenta, bg = p.bg1 })
hl("MiniClueDescSingle", { fg = p.fg, bg = p.bg1 })
hl("MiniClueNextKey", { fg = p.blue, bg = p.bg1 })
hl("MiniClueNextKeyWithPostkeys", { fg = p.magenta, bg = p.bg1 })
hl("MiniClueSeparator", { fg = p.bg3, bg = p.bg1 })
hl("MiniClueTitle", { fg = p.cyan, bg = p.bg1, bold = true })

-- mini.cmdline
hl("MiniCmdlinePeekBorder", { link = "FloatBorder" })
hl("MiniCmdlinePeekLineNr", { fg = p.grey1, bg = p.bg1 })
hl("MiniCmdlinePeekNormal", { link = "NormalFloat" })
hl("MiniCmdlinePeekSep", { fg = p.bg3, bg = p.bg1 })
hl("MiniCmdlinePeekSign", { fg = p.cyan, bg = p.bg1 })
hl("MiniCmdlinePeekTitle", { link = "FloatTitle" })

-- mini.completion
hl("MiniCompletionActiveParameter", { link = "LspSignatureActiveParameter" })
hl("MiniCompletionDeprecated", { link = "DiagnosticDeprecated" })
hl("MiniCompletionInfoBorderOutdated", { link = "DiagnosticFloatingWarn" })

-- mini.cursorword
hl("MiniCursorword", { underline = true })
hl("MiniCursorwordCurrent", { underline = true })

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
hl("MiniFilesBorder", { fg = p.bg3, bg = p.bg1 })
hl("MiniFilesBorderModified", { link = "DiagnosticFloatingWarn" })
hl("MiniFilesCursorLine", { bg = p.bg3 })
hl("MiniFilesDirectory", { link = "Directory" })
hl("MiniFilesFile", { fg = p.fg })
hl("MiniFilesNormal", { fg = p.fg, bg = p.bg1 })
hl("MiniFilesTitle", { fg = p.grey1, bg = p.bg1, bold = true })
hl("MiniFilesTitleFocused", { fg = p.cyan, bg = p.bg1, bold = true })

-- mini.hipatterns (FIXME / TODO / WARN / NOTE)
hl("MiniHipatternsFixme", { link = "@comment.error" })
hl("MiniHipatternsTodo", { link = "@comment.todo" })
hl("MiniHipatternsWarn", { link = "@comment.warning" })
hl("MiniHipatternsNote", { link = "@comment.note" })

-- mini.icons (link to closest named palette color)
hl("MiniIconsAzure", { fg = p.cyan })
hl("MiniIconsBlue", { fg = p.blue })
hl("MiniIconsCyan", { fg = p.cyan })
hl("MiniIconsGreen", { fg = p.green })
hl("MiniIconsGrey", { fg = p.grey1 })
hl("MiniIconsOrange", { fg = p.orange })
hl("MiniIconsPurple", { fg = p.magenta })
hl("MiniIconsRed", { fg = p.red })
hl("MiniIconsYellow", { fg = p.yellow })

-- mini.indentscope (subtle indent guides that blend into the background)
hl("MiniIndentscopeSymbol", { fg = p.bg3 })
hl("MiniIndentscopeSymbolOff", { fg = p.red })

-- mini.jump
hl("MiniJump", { sp = p.cyan, undercurl = true })

-- mini.jump2d
hl("MiniJump2dDim", { fg = p.bg3 })
hl("MiniJump2dSpot", { fg = p.bg, bg = p.fg_bright, bold = true, nocombine = true })
hl("MiniJump2dSpotAhead", { fg = p.bg, bg = p.fg, nocombine = true })
hl("MiniJump2dSpotUnique", { link = "MiniJump2dSpot" })

-- mini.map
hl("MiniMapNormal", { fg = p.grey1, bg = p.bg2 })
hl("MiniMapSymbolCount", { fg = p.grey1 })
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
hl("MiniPickBorder", { fg = p.bg3, bg = p.bg1 })
hl("MiniPickBorderBusy", { link = "DiagnosticFloatingWarn" })
hl("MiniPickBorderText", { fg = p.cyan, bg = p.bg1, bold = true })
hl("MiniPickCursor", { blend = 100, nocombine = true })
hl("MiniPickIconDirectory", { link = "Directory" })
hl("MiniPickIconFile", { link = "MiniPickNormal" })
hl("MiniPickHeader", { fg = p.magenta, bold = true })
hl("MiniPickMatchCurrent", { bg = p.bg3 })
hl("MiniPickMatchMarked", { bg = p.bg3, bold = true })
hl("MiniPickMatchRanges", { fg = p.cyan, bold = true })
hl("MiniPickNormal", { fg = p.fg, bg = p.bg1 })
hl("MiniPickPreviewLine", { link = "CursorLine" })
hl("MiniPickPreviewRegion", { link = "IncSearch" })
hl("MiniPickPrompt", { fg = p.fg, bg = p.bg1 })
hl("MiniPickPromptCaret", { fg = p.fg, bg = p.bg1 })
hl("MiniPickPromptPrefix", { fg = p.cyan, bg = p.bg1 })

-- mini.snippets
hl("MiniSnippetsCurrent", { sp = p.yellow, underdouble = true })
hl("MiniSnippetsCurrentReplace", { sp = p.red, underdouble = true })
hl("MiniSnippetsFinal", { sp = p.green, underdouble = true })
hl("MiniSnippetsUnvisited", { sp = p.cyan, underdouble = true })
hl("MiniSnippetsVisited", { sp = p.blue, underdouble = true })

-- mini.starter
hl("MiniStarterCurrent", { link = "MiniStarterItem" })
hl("MiniStarterFooter", { link = "Comment" })
hl("MiniStarterHeader", { fg = p.cyan, bg = p.bg1, bold = true })
hl("MiniStarterInactive", { link = "Comment" })
hl("MiniStarterItem", { link = "Normal" })
hl("MiniStarterItemBullet", { fg = p.grey1 })
hl("MiniStarterItemPrefix", { fg = p.blue, bold = true })
hl("MiniStarterSection", { fg = p.magenta, bold = true })
hl("MiniStarterQuery", { fg = p.cyan, bold = true })

-- mini.statusline
hl("MiniStatuslineModeNormal", { fg = p.bg, bg = p.fg, bold = true })
hl("MiniStatuslineModeInsert", { fg = p.bg, bg = p.cyan, bold = true })
hl("MiniStatuslineModeVisual", { fg = p.bg, bg = p.magenta, bold = true })
hl("MiniStatuslineModeReplace", { fg = p.bg, bg = p.red, bold = true })
hl("MiniStatuslineModeCommand", { fg = p.bg, bg = p.yellow, bold = true })
hl("MiniStatuslineModeOther", { fg = p.bg, bg = p.navy, bold = true })
hl("MiniStatuslineDevinfo", { fg = p.fg, bg = p.bg1 })
hl("MiniStatuslineFilename", { fg = p.fg, bg = p.bg1 })
hl("MiniStatuslineFileinfo", { link = "MiniStatuslineDevinfo" })
hl("MiniStatuslineInactive", { link = "StatusLineNC" })

-- mini.surround
hl("MiniSurround", { link = "IncSearch" })

-- mini.tabline (bufferline)
hl("MiniTablineCurrent", { fg = p.fg, bg = p.bg, bold = true })
hl("MiniTablineVisible", { fg = p.grey1, bg = p.bg1, bold = true })
hl("MiniTablineHidden", { fg = p.grey1, bg = p.bg1 })
hl("MiniTablineModifiedCurrent", { fg = p.navy, bg = p.bg, bold = true, italic = true })
hl("MiniTablineModifiedVisible", { fg = p.navy, bg = p.bg1, bold = true, italic = true })
hl("MiniTablineModifiedHidden", { fg = p.navy, bg = p.bg1, italic = true })
hl("MiniTablineFill", { link = "MiniTablineHidden" })
hl("MiniTablineTabpagesection", { fg = p.fg, bg = p.bg1, bold = true })
hl("MiniTablineTrunc", { fg = p.grey1, bg = p.bg1, bold = true })

-- mini.test
hl("MiniTestEmphasis", { bold = true })
hl("MiniTestFail", { fg = p.red, bold = true })
hl("MiniTestPass", { fg = p.green, bold = true })

-- mini.trailspace
hl("MiniTrailspace", { bg = p.deep_yellow })
-- }}}

-- 9. Octo (GitHub PR review) ----------------------------------------------- {{{
-- octo.nvim derives its `Octo*` groups from a `colors` table at setup time,
-- but guards each one with `hlexists` (see octo/ui/colors.lua), so any group
-- we define here wins and octo defers to it.

-- Bubbles
hl("OctoBubbleBlue", { fg = p.fg_bright, bg = p.deep_blue })
hl("OctoBubbleYellow", { fg = p.fg_bright, bg = p.deep_yellow })
hl("OctoBubblePurple", { fg = p.fg_bright, bg = p.deep_magenta })
hl("OctoBubbleDelimiterYellow", { fg = p.deep_yellow })

-- File panel
hl("OctoFilePanelTitle", { fg = p.magenta, bold = true })
hl("OctoFilePanelFileName", { fg = p.fg })
hl("OctoFilePanelCursorLine", { bg = p.bg2 })
-- }}}

-- 10. Misc ----------------------------------------------------------------- {{{

-- Quickfix
hl("qfLineNr", { fg = p.grey0 })
hl("qfFileName", { fg = p.blue })

-- Inline git blame (lua/blame.lua)
hl("BlameInline", { fg = p.grey0, italic = true })

-- Codenotes sign glyph (lua/codenotes.lua)
hl("CodenoteSign", { fg = p.navy })

-- Nvim built-in float popup title conventions
hl("NvimInternalError", { fg = p.red })

-- Neovim health check
hl("healthError", { fg = p.red })
hl("healthWarning", { fg = p.yellow })
hl("healthSuccess", { fg = p.green })
-- }}}

-- Set colors_name LAST (signals successful load to Neovim)
vim.g.colors_name = "nord-deep"
