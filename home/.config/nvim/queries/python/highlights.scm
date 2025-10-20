;  ____        _   _
; |  _ \ _   _| |_| |__   ___  _ __
; | |_) | | | | __| '_ \ / _ \| '_ \
; |  __/| |_| | |_| | | | (_) | | | |
; |_|    \__, |\__|_| |_|\___/|_| |_|
;        |___/
;
; Queries for tree-sitter highlighting.
; Intended to be used with tree-sitter-python.

; Keywords
[
    "and"
    "as"
    "assert"
    "break"
    "class"
    "continue"
    "def"
    "else"
    "elif"
    "except"
    "finally"
    "for"
    "from"
    "global"
    "if"
    "in"
    "is"
    "import"
    "lambda"
    "not"
    "or"
    "pass"
    "raise"
    "return"
    "try"
    "while"
    "with"
]  @keyword

; Punctuations
[
    ","
    ":"
] @punctuation.delimiter

[
    "("
    ")"
    "["
    "]"
    "{"
    "}"
] @punctuation.bracket

; Operators
[
    "."
    "+"
    "-"
    "*"
    "/"
    "%"
    "**"
    "//"
    "&"
    "|"
    "^"
    "<<"
    ">>"
    "="
    ":="
    "+="
    "-="
    "*="
    "/="
    "%="
    "&="
    "|="
    "^="
    "**="
    "//="
    "<<="
    ">>="
    "<"
    ">"
    "=="
    "!="
    "<="
    ">="
] @operator

; General
(integer) @number
(string) @string
(comment) @comment

; Constants
(true) @constant
(false) @constant

; Types
(type
    (identifier) @type)
(class_definition
    (identifier) @type)
((identifier) @type.builtin
    (#eq? @type.builtin "int")
    (#set! priority 101))

; Functions
(function_definition
    name: (identifier) @function)
(call
    function: (identifier) @function.call)
(call
    function: (identifier) @function.builtin
    (#eq? @function.builtin "type"))

; Variables
((identifier) @variable
    (#set! priority 95))
(((identifier) @variable.builtin)
    (#eq? @variable.builtin "__name__"))
(parameters
    (identifier) @variable.parameter)
(attribute
    attribute: (identifier) @property)
