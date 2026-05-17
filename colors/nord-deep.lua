-- Nord Deep — an arctic, north-bluish color palette taken to deeper depths.
-- See https://github.com/nbetm/nix-config/blob/main/docs/nord-deep.md for
-- the palette spec and design language.
--
-- Activate with `:colorscheme nord-deep`.
-- Toggle transparent background by setting `vim.g.nord_deep_transparent = 1`
-- before loading (e.g. in init.lua before `colorscheme nord-deep`).

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end

local hl = function(name, opts) vim.api.nvim_set_hl(0, name, opts) end

-- Alpha-composite two hex colors: `ratio` of `b` over `a`. Used to derive soft
-- overlays (e.g. cursorline) without baking magic hex into the palette. The
-- design doc describes these as transparency (e.g. `#2e344080` = surface @ 50%);
-- Neovim hl groups don't honor alpha, so the result is precomputed here.
local blend = function(a, b, ratio)
  local ar, ag, ab = a:match("#(%x%x)(%x%x)(%x%x)")
  local br, bg_, bb = b:match("#(%x%x)(%x%x)(%x%x)")
  local mix = function(x, y) return math.floor(tonumber(x, 16) * (1 - ratio) + tonumber(y, 16) * ratio + 0.5) end
  return string.format("#%02x%02x%02x", mix(ar, br), mix(ag, bg_), mix(ab, bb))
end

-- Palette ------------------------------------------------------------------ {{{
local palette = {
  -- Polar Night
  base = "#212732",
  surface = "#2e3440",
  elevated = "#3b4252",
  chrome = "#434c5e",
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
  none = "NONE",
}
-- Derived overlays. Kept separate so the alpha-composite intent is visible.
palette.cursorline = blend(palette.base, palette.surface, 0.5) -- surface @ 50% on base

local p = palette
local transparent = vim.g.nord_deep_transparent
local bg = transparent and palette.none or palette.base
-- }}}

-- 1. Editor core ----------------------------------------------------------- {{{
hl("Normal", { fg = p.text, bg = bg })
hl("NormalNC", { fg = p.text, bg = bg })
hl("NormalFloat", { fg = p.text, bg = p.surface })
hl("EndOfBuffer", { fg = p.chrome, bg = transparent and p.none or nil })

hl("Cursor", { fg = p.base, bg = p.text })
hl("CursorIM", { link = "Cursor" })
hl("lCursor", { link = "Cursor" })
hl("CursorLine", { bg = p.cursorline })
hl("CursorColumn", { bg = p.cursorline })
hl("CursorLineNr", { fg = p.text, bg = p.cursorline })

hl("LineNr", { fg = p.chrome })
hl("LineNrAbove", { fg = p.chrome })
hl("LineNrBelow", { fg = p.chrome })

hl("SignColumn", { fg = p.chrome, bg = transparent and p.none or p.base })
hl("FoldColumn", { fg = p.chrome, bg = p.base })
hl("Folded", { link = "NordFadedSurface" })

hl("Visual", { bg = p.elevated })
hl("VisualNOS", { bg = p.elevated })

-- Pmenu (cmdline + LSP completion) — raised tier, same `surface` bg as
-- notify/hover/peek. Selection and matches reuse the picker aliases.
hl("Pmenu", { link = "NormalFloat" })
hl("PmenuBorder", { link = "FloatBorder" })
hl("PmenuSel", { link = "NordRowCurrent" })
hl("PmenuMatch", { link = "NordEntryMatch" })
hl("PmenuMatchSel", { link = "NordEntryMatch" })
hl("PmenuSbar", { bg = p.elevated })
hl("PmenuThumb", { bg = p.navy })
hl("PmenuKind", { fg = p.aqua, bg = p.surface })
hl("PmenuKindSel", { fg = p.aqua, bg = p.elevated })
hl("PmenuExtra", { link = "NordFadedSurface" })
hl("PmenuExtraSel", { fg = p.dim, bg = p.elevated })

hl("StatusLine", { fg = p.text, bg = p.elevated })
hl("StatusLineNC", { link = "NordFadedSurface" })
hl("TabLine", { link = "NordFadedSurface" })
hl("TabLineSel", { fg = p.text, bg = p.base })
hl("TabLineFill", { bg = p.surface })

hl("WinSeparator", { fg = p.chrome })
hl("VertSplit", { fg = p.chrome })
hl("WinBar", { fg = p.text, bg = p.surface })
hl("WinBarNC", { link = "NordFadedSurface" })

hl("FloatBorder", { fg = p.chrome, bg = p.surface })
hl("FloatTitle", { fg = p.text, bg = p.surface, bold = true })
hl("FloatFooter", { link = "NordFadedSurface" })

hl("ColorColumn", { bg = p.cursorline })
hl("Conceal", { fg = p.chrome })
hl("Directory", { fg = p.blue })
hl("Title", { fg = p.cyan, bold = true })
hl("MatchParen", { fg = p.orange, bold = true })

hl("NonText", { link = "NordLayoutMarker" })
hl("SpecialKey", { link = "NordLayoutMarker" })
hl("Whitespace", { link = "NordLayoutMarker" })

hl("MsgArea", { fg = p.text })
hl("MoreMsg", { fg = p.cyan })
hl("ErrorMsg", { fg = p.red })
hl("WarningMsg", { fg = p.yellow })
hl("Question", { fg = p.cyan })
hl("MsgSeparator", { fg = p.chrome, bg = p.surface })

hl("QuickFixLine", { fg = p.base, bg = p.orange })
hl("WildMenu", { link = "NordRowCurrent" })

hl("Underlined", { underline = true })
hl("Bold", { bold = true })
hl("Italic", { italic = true })

-- Inlay hints
hl("LspInlayHint", { link = "Comment" })
hl("LspSignatureActiveParameter", { fg = p.text, bg = p.elevated, bold = true })
hl("LspReferenceText", { bg = p.elevated })
hl("LspReferenceRead", { bg = p.elevated })
hl("LspReferenceWrite", { bg = p.elevated })
hl("LspCodeLens", { link = "Comment" })
hl("LspCodeLensSeparator", { fg = p.chrome })

-- Terminal colors (maps to palette entries)
vim.g.terminal_color_0 = p.elevated -- color0  (black)
vim.g.terminal_color_1 = p.red -- color1  (red)
vim.g.terminal_color_2 = p.green -- color2  (green)
vim.g.terminal_color_3 = p.yellow -- color3  (yellow)
vim.g.terminal_color_4 = p.blue -- color4  (blue)
vim.g.terminal_color_5 = p.magenta -- color5  (magenta)
vim.g.terminal_color_6 = p.cyan -- color6  (cyan)
vim.g.terminal_color_7 = p.text -- color7  (white)
vim.g.terminal_color_8 = p.chrome -- color8  (bright black)
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

-- Virtual text, signs (gutter), floating window — all share the base color
-- per severity, so just link instead of repeating values.
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

-- Underline uses `sp` + `undercurl`, distinct from the fg-only base groups.
hl("DiagnosticUnderlineError", { sp = p.red, undercurl = true })
hl("DiagnosticUnderlineWarn", { sp = p.yellow, undercurl = true })
hl("DiagnosticUnderlineInfo", { sp = p.navy, undercurl = true })
hl("DiagnosticUnderlineHint", { sp = p.navy, undercurl = true })
hl("DiagnosticUnderlineOk", { sp = p.green, undercurl = true })

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
hl("SpecialComment", { link = "Comment" })
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
hl("@comment.todo", { link = "Todo" })
hl("@comment.note", { fg = p.base, bg = p.navy, bold = true })

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
-- Bare `@markup.heading` (no level) is what markdown treesitter assigns to
-- pipe-table header cells. Keep it distinct from section headings so the two
-- don't both land on magenta and visually blur together inside docs with tables.
hl("@markup.heading", { fg = p.bright, bold = true })
hl("@markup.heading.1", { link = "NordSemanticHeader" })
hl("@markup.heading.2", { link = "NordSemanticHeader" })
hl("@markup.heading.3", { link = "NordSemanticHeader" })
hl("@markup.heading.4", { link = "NordSemanticHeader" })
hl("@markup.heading.5", { link = "NordSemanticHeader" })
hl("@markup.heading.6", { link = "NordSemanticHeader" })

hl("@markup.heading.1.delimiter.vimdoc", { fg = p.chrome, bold = true })
hl("@markup.heading.2.delimiter.vimdoc", { fg = p.chrome, bold = true })
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
hl("@markup.list.unchecked", { fg = p.chrome })

hl("@markup.quote", { fg = p.navy })
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
-- hl("@parameter", { fg = p.text })
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
hl("markdownBlockquote", { fg = p.navy })
-- }}}

-- 8. Theme aliases --------------------------------------------------------- {{{
-- Captures the design language so module-specific groups link instead of
-- duplicating values. Tweaking a tier value (e.g., shifting `bg` for sunken
-- floats) becomes a one-line change.
--
-- Design language at a glance:
--
--   Polar Night ladder (bg shades, dark → light)
--     base     — canvas / foundation
--     surface  — slightly above (the "Raised" float tier)
--     elevated — more lift (current row, statusline active)
--     chrome   — brightest polar, borders / separators
--
--   Float tiers
--     Sunken (bg = base)    — workspace surfaces (pickers, explorer, clue)
--     Raised (bg = surface) — transient feedback (notify, hover, peek, Pmenu)
--
--   Chrome strips (tabline / statusline) — intentionally asymmetric
--     Tabline current tab = base (sinks to canvas).
--       Tabs represent buffers; the current tab visually merges with the
--       buffer it shows. Same "active workspace surface = canvas extension"
--       logic as sunken floats.
--     Statusline active sections = elevated (rises above canvas).
--       Statusline is a meta-info strip, not a workspace surface. It rises
--       so the strip reads as a distinct layer rather than buffer content.
--     Both fall to `surface` for inactive / mid-recessed sections.
--
--   Semantic color channels
--     cyan    = live as-you-type matching: prompt prefix `❱`, sunken titles,
--               picker/pmenu matches (bold), IncSearch in the buffer. Frost
--               accent for "you're typing a query, here's what it matches."
--     orange  = committed / paired result: CurSearch (the hit you'll jump
--               to after Enter), MatchParen (bracket pair), clue's submode
--               keys. Reads as "this is the resolved match."
--     yellow  = passive attention / warm caution: search results (Search),
--               warning severity (DiagnosticWarn, Todo, todo-class comments),
--               diff changes (DiffChange). Visible but not alarming.
--     magenta = navigational landmark (headers, group entries)
--     blue    = actionable key (clue NextKey, starter prefix)
--     navy    = secondary informational (info & hint diagnostics, inline
--               blame, blockquotes, NOTE markers — visible but not loud)
--     aqua    = type / structure noun (Type, code spans, @property/@field,
--               LSP kinds). Frost sibling to cyan; mostly syntax.
--     chrome  = visible polar trim (borders, separators)
--     dim     = faded / inactive (unfocused titles)
--     text    = neutral typed input + caret (filter prompt body, caret
--               blends with what you're typing)
--
--   Row state hierarchy
--     Marked (bg = elevated, bold) > Current (bg = elevated) > Default
--     Marked differs from Current by typographic weight + mini.pick's
--     prefix glyph, not by bg shade. Keeps `chrome` reserved as a pure
--     trim (fg) color, no dual role.
--
--   Other rules
--     Selection modulates bg only — fg falls through to entry color.
--     Severity (red/yellow/navy) reserved for actual attention, not noise.
--     Focus signaled by fade — active stays at baseline, inactive dims.
--     Borders and separators sit at `chrome` (brightest polar shade).
--
-- Full tool-agnostic spec: https://github.com/nbetm/nix-config/blob/main/docs/nord-deep.md

-- Sunken float tier (pickers, explorer, clue). Workspace surfaces painted
-- on editor `bg`. Notify, hover, diagnostic float, completion info, peek,
-- and Pmenu stay raised on NormalFloat/FloatBorder.
hl("NordSunkenNormal", { fg = p.text, bg = bg })
hl("NordSunkenBorder", { fg = p.chrome, bg = bg })
hl("NordSunkenTitle", { fg = p.cyan, bg = bg, bold = true })
hl("NordSunkenTitleDim", { fg = p.dim, bg = bg, bold = true })

-- Row state — three-tier hierarchy: Marked (intent) > Current (cursor) >
-- Default (no bg). Brighter bg = more user attention.
hl("NordRowMarked", { bg = p.elevated, bold = true })
hl("NordRowCurrent", { bg = p.elevated })

-- Prompt cue — prompt prefix and caret. The "you're typing here" accent for
-- the picker query area. Doesn't apply to titles (those are NordSunkenTitle)
-- or to matched content (that's NordEntryMatch).
hl("NordPromptCue", { fg = p.cyan })

-- Matched content — picker matched chars, completion-popup matched chars.
-- `cyan + bold`: picks up the palette's primary accent on most kinds (a color
-- shift signals "this is the match"); on cyan-fg entries (Function/Method,
-- where the symbol picker also uses cyan) the bold weight carries the
-- distinction. Stays Frost-dominant; doesn't pull the picker toward Aurora.
hl("NordEntryMatch", { fg = p.cyan, bold = true })

-- Navigational landmark — section headers, group entries that descend deeper.
-- Inline-only callers (mini.clue's DescGroup, which needs an explicit bg due
-- to the noautocmd quirk) keep their literal `fg = p.magenta` instead.
hl("NordSemanticHeader", { fg = p.magenta, bold = true })

-- Faded content on the raised float bg. Used by inactive statusline / tabline
-- sections, fold lines, completion extra info, footer text, etc.
hl("NordFadedSurface", { fg = p.dim, bg = p.surface })

-- Layout markers — whitespace listchars, indent guides, jump-target dimming.
-- Structural trim, same tier as LineNr.
hl("NordLayoutMarker", { fg = p.chrome })
-- }}}

-- 9. mini.nvim groups ------------------------------------------------------ {{{

-- mini.animate
hl("MiniAnimateCursor", { reverse = true, nocombine = true })
hl("MiniAnimateNormalFloat", { link = "NormalFloat" })

-- mini.clue
-- Inline groups (NextKey/Separator/DescGroup/etc.) need explicit `bg = bg`:
-- clue opens with `noautocmd = true`, so a winhighlight autocmd can't remap
-- NormalFloat — fg-only extmarks would otherwise inherit surface.
hl("MiniClueBorder", { link = "NordSunkenBorder" })
hl("MiniClueDescGroup", { fg = p.magenta, bg = bg })
hl("MiniClueDescSingle", { link = "NordSunkenNormal" })
hl("MiniClueNextKey", { fg = p.blue, bg = bg })
hl("MiniClueNextKeyWithPostkeys", { fg = p.magenta, bg = bg })
hl("MiniClueSeparator", { fg = p.chrome, bg = bg })
hl("MiniClueTitle", { link = "NordSunkenTitle" })

-- mini.cmdline
hl("MiniCmdlinePeekBorder", { link = "FloatBorder" })
hl("MiniCmdlinePeekLineNr", { fg = p.dim, bg = p.surface })
hl("MiniCmdlinePeekNormal", { link = "NormalFloat" })
hl("MiniCmdlinePeekSep", { fg = p.chrome, bg = p.surface })
hl("MiniCmdlinePeekSign", { fg = p.cyan, bg = p.surface })
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
hl("MiniFilesBorder", { link = "NordSunkenBorder" })
hl("MiniFilesBorderModified", { link = "DiagnosticFloatingWarn" })
hl("MiniFilesCursorLine", { link = "NordRowCurrent" })
hl("MiniFilesDirectory", { link = "Directory" })
hl("MiniFilesFile", { fg = p.text })
hl("MiniFilesNormal", { link = "NordSunkenNormal" })
hl("MiniFilesTitle", { link = "NordSunkenTitleDim" })
hl("MiniFilesTitleFocused", { link = "NordSunkenTitle" })

-- mini.hipatterns (FIXME=red, TODO=yellow, NOTE=navy)
hl("MiniHipatternsFixme", { fg = p.base, bg = p.red, bold = true })
hl("MiniHipatternsTodo", { link = "Todo" })
hl("MiniHipatternsNote", { link = "@comment.note" })

-- mini.icons (link to closest named palette color)
-- mini.icons named-color groups → palette. Azure → cyan and Purple → magenta
-- because the palette doesn't have those exact names.
hl("MiniIconsAzure", { fg = p.cyan })
hl("MiniIconsBlue", { fg = p.blue })
hl("MiniIconsCyan", { fg = p.cyan })
hl("MiniIconsGreen", { fg = p.green })
hl("MiniIconsGrey", { fg = p.dim })
hl("MiniIconsOrange", { fg = p.orange })
hl("MiniIconsPurple", { fg = p.magenta })
hl("MiniIconsRed", { fg = p.red })
hl("MiniIconsYellow", { fg = p.yellow })

-- mini.indentscope (subtle indent guides that blend into the background)
hl("MiniIndentscopeSymbol", { link = "NordLayoutMarker" })
hl("MiniIndentscopeSymbolOff", { fg = p.red })

-- mini.jump
hl("MiniJump", { sp = p.cyan, undercurl = true })

-- mini.jump2d
hl("MiniJump2dDim", { link = "NordLayoutMarker" })
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
hl("MiniPickBorder", { link = "NordSunkenBorder" })
hl("MiniPickBorderBusy", { link = "DiagnosticFloatingWarn" })
hl("MiniPickBorderText", { link = "NordSunkenTitle" })
hl("MiniPickCursor", { blend = 100, nocombine = true })
hl("MiniPickIconDirectory", { link = "Directory" })
hl("MiniPickIconFile", { link = "MiniPickNormal" })
hl("MiniPickHeader", { link = "NordSemanticHeader" })
hl("MiniPickMatchCurrent", { link = "NordRowCurrent" })
hl("MiniPickMatchMarked", { link = "NordRowMarked" })
hl("MiniPickMatchRanges", { link = "NordEntryMatch" })
hl("MiniPickNormal", { link = "NordSunkenNormal" })
hl("MiniPickPreviewLine", { link = "CursorLine" })
hl("MiniPickPreviewRegion", { link = "IncSearch" })
hl("MiniPickPrompt", { fg = p.text })
hl("MiniPickPromptCaret", { fg = p.text })
hl("MiniPickPromptPrefix", { link = "NordPromptCue" })

-- mini.snippets
hl("MiniSnippetsCurrent", { sp = p.yellow, underdouble = true })
hl("MiniSnippetsCurrentReplace", { sp = p.red, underdouble = true })
hl("MiniSnippetsFinal", { sp = p.green, underdouble = true })
hl("MiniSnippetsUnvisited", { sp = p.cyan, underdouble = true })
hl("MiniSnippetsVisited", { sp = p.blue, underdouble = true })

-- mini.starter
hl("MiniStarterCurrent", { link = "MiniStarterItem" })
hl("MiniStarterFooter", { link = "Comment" })
hl("MiniStarterHeader", { link = "NordSunkenTitle" })
hl("MiniStarterInactive", { link = "Comment" })
hl("MiniStarterItem", { link = "Normal" })
hl("MiniStarterItemBullet", { fg = p.dim })
hl("MiniStarterItemPrefix", { fg = p.blue, bold = true })
hl("MiniStarterSection", { link = "NordSemanticHeader" })
hl("MiniStarterQuery", { link = "NordEntryMatch" })

-- mini.statusline. Each mode gets a distinct palette color so you can read
-- the active mode at a glance.
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

-- mini.tabline (bufferline — inactive tabs on surface, active on base)
hl("MiniTablineCurrent", { fg = p.text, bg = p.base, bold = true })
hl("MiniTablineVisible", { fg = p.dim, bg = p.surface, bold = true })
hl("MiniTablineHidden", { link = "NordFadedSurface" })
hl("MiniTablineModifiedCurrent", { fg = p.navy, bg = p.base, bold = true, italic = true })
hl("MiniTablineModifiedVisible", { fg = p.navy, bg = p.surface, bold = true, italic = true })
hl("MiniTablineModifiedHidden", { fg = p.navy, bg = p.surface, italic = true })
hl("MiniTablineFill", { link = "MiniTablineHidden" })
hl("MiniTablineTabpagesection", { fg = p.text, bg = p.elevated, bold = true })
hl("MiniTablineTrunc", { fg = p.dim, bg = p.surface, bold = true })

-- mini.test
hl("MiniTestEmphasis", { bold = true })
hl("MiniTestFail", { fg = p.red, bold = true })
hl("MiniTestPass", { fg = p.green, bold = true })

-- mini.trailspace
hl("MiniTrailspace", { bg = p.red })
-- }}}

-- 10. Misc ----------------------------------------------------------------- {{{

-- Quickfix
hl("qfLineNr", { fg = p.chrome })
hl("qfFileName", { fg = p.blue })

-- Inline git blame (lua/blame.lua) — navy reads as "annotation that lives
-- next to live code without competing for attention with Aurora warnings."
hl("BlameInline", { fg = p.navy })

-- Codenotes sign glyph (lua/codenotes.lua) — same navy channel as blame:
-- a personal informational marker, present in the gutter without screaming.
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
