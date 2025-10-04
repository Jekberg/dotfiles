;      _ ____   ___  _   _
;     | / ___| / _ \| \ | |
;  _  | \___ \| | | |  \| |
; | |_| |___) | |_| | |\  |
;  \___/|____/ \___/|_| \_|
;
; Queries for tree-sitter highlighting.
; This is written for tree-sitter-json

[
    "{"
    "}"
    "["
    "]"
] @punctuation.bracket

[
    ":"
    ","
] @punctuation.delimiter

(string) @string (#set! priority 95)
(number) @number
(pair
    key: (string) @property)
