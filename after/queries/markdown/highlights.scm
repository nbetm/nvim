; extends

; Recapture fenced-code-block delimiters (``` and ~~~) as punctuation.special
; instead of @markup.raw.block (which the upstream query uses for both the
; delimiters and the code body). With this override the delimiters take a
; punctuation color while the body falls through to either an injected
; language or @markup.raw.block (aqua) as a fallback.
((fenced_code_block_delimiter) @punctuation.special)
