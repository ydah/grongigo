# frozen_string_literal: true

require_relative 'ast/node'
require_relative 'ast/program'
require_relative 'ast/function_decl'
require_relative 'ast/parameter'
require_relative 'ast/var_decl'

# Statements
require_relative 'ast/block_stmt'
require_relative 'ast/if_stmt'
require_relative 'ast/while_stmt'
require_relative 'ast/for_stmt'
require_relative 'ast/return_stmt'
require_relative 'ast/break_stmt'
require_relative 'ast/continue_stmt'
require_relative 'ast/expr_stmt'
require_relative 'ast/switch_stmt'
require_relative 'ast/case_clause'

# Expressions
require_relative 'ast/binary_expr'
require_relative 'ast/unary_expr'
require_relative 'ast/assign_expr'
require_relative 'ast/call_expr'
require_relative 'ast/index_expr'
require_relative 'ast/identifier'
require_relative 'ast/number_literal'
require_relative 'ast/string_literal'
require_relative 'ast/char_literal'
