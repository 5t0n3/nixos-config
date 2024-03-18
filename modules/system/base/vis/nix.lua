local l = require('lexer')
local token, word_match = l.token, l.word_match
local P, S = lpeg.P, lpeg.S

local M = { _NAME = 'nix' }

-- Whitespace
local ws = token(l.WHITESPACE, l.space^1)

-- Keywords
local keyword = token(l.KEYWORD, word_match{
  'let', 'in', 'with', 'inherit', 'import', 'builtins', 'if', 'then', 
  'else', 'true', 'false', 'rec'
})

-- Comments
local comment = token(l.COMMENT, '#' * l.nonnewline_esc^0)

-- Identifiers
local identifier = token(l.IDENTIFIER, (l.alpha + '_') * (l.alnum + S('-_'))^0)

-- Strings & paths
local dq_str = l.delimited_range('"')
local multiline_str = "''" * (l.any - "''")^0 * "''"
local path_segment = (l.alnum + S('-_'))^1 + '.' + '..'
local path = P('.')^-2 * ('/' * path_segment)^1 * ('/' + ('.' * l.alnum^1))^-1
local str = token(l.STRING, dq_str + multiline_str + path)

-- Numbers
local number = token(l.NUMBER, l.float + l.integer)

-- Operators
local operator = token(l.OPERATOR, S('+-/*<>!=@&|?;,.()[]{}'))

M._rules = {
  {'whitespace', ws},
  {'keyword', keyword},
  {'identifier', identifier},
  {'string', str},
  {'comment', comment},
  {'number', number},
  {'operator', operator}
}

return M
