; extends

; Recapture emphasis (`*`, `_`, `**`) and inline-code (`` ` ``) delimiters as
; punctuation.special instead of leaving them on the upstream @conceal capture
; (which carries no fg of its own, so the markers visually fell through to the
; surrounding @markup.strong/italic/raw color). The upstream `conceal` metadata
; is preserved by the original rule, so `conceallevel=2` still hides them.
((emphasis_delimiter) @punctuation.special)
((code_span_delimiter) @punctuation.special)
