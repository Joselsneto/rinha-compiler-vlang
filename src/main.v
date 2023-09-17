module main

import os
import x.json2

struct File {
	name string
	expression Term
}

struct Print {
	value Term
}

struct Str {
	value string
}

struct Int {
	value int
}

struct Bool {
	value bool
}

struct If {
	condition Term
	then Term
	otherwise Term
}

struct Parameter {
	text string
}

struct Var {
	text string
}

struct Function {
	parameters []Parameter
	value Term
}

struct Call {
	callee Term
	arguments []Term
}

struct Let {
	name Parameter
	value Term
	next Term
}

struct Binary {
	lhs Term
	op BinaryOp
	rhs Term
}

struct Tuple {
	first Term
	second Term
}

struct First {
	value Term
}

struct Second {
	value Term
}

enum BinaryOp {
	@none
	add
	sub
	mul
	div
	rem
	eq
	neq
	lt
	gt
	lte
	gte
	and
	orop
}

type Term = Print | Str | string | int | bool | Int | Bool | Call | Binary | Function | Let | If | First | Second | Tuple | Var

fn sum(lhs Term, rhs Term) Term {
	if lhs is int && rhs is int {
		lhs_value := lhs as int
		rhs_value := rhs as int
		return lhs_value + rhs_value
	}
	if lhs is int {
		lhs_value := int(lhs).str()
		rhs_value := rhs as string
		return lhs_value + rhs_value
	}
	if rhs is int {
		lhs_value := lhs as string
		rhs_value := int(rhs).str()
		return lhs_value + rhs_value
	}
	lhs_value := lhs as string
	rhs_value := rhs as string
	return lhs_value + rhs_value
}

fn solve_binary_op(lhs Term, binary_op BinaryOp, rhs Term) Term {
	match binary_op {
		.add {
			return sum(lhs, rhs)
		}
		.sub {
			lhs_value := lhs as int
			rhs_value := rhs as int
			return lhs_value - rhs_value
		}
		.mul {
			lhs_value := lhs as int
			rhs_value := rhs as int
			return lhs_value * rhs_value
		}
		.div {
			lhs_value := lhs as int
			rhs_value := rhs as int
			return lhs_value / rhs_value
		}
		.rem {
			lhs_value := lhs as int
			rhs_value := rhs as int
			return lhs_value % rhs_value
		}
		.eq {
			return lhs == rhs
		}
		.neq {
			return lhs != rhs
		}
		.lt {
			lhs_value := lhs as int
			rhs_value := rhs as int
			return lhs_value < rhs_value
		}
		.gt {
			lhs_value := lhs as int
			rhs_value := rhs as int
			return lhs_value > rhs_value
		}
		.lte {
			lhs_value := lhs as int
			rhs_value := rhs as int
			return lhs_value <= rhs_value
		}
		.gte {
			lhs_value := lhs as int
			rhs_value := rhs as int
			return lhs_value >= rhs_value
		}
		.and {
			lhs_value := lhs as bool
			rhs_value := rhs as bool
			return lhs_value && rhs_value
		}
		.orop {
			lhs_value := lhs as bool
			rhs_value := rhs as bool
			return lhs_value || rhs_value
		}
		else {
			return ""
		}
	}
}

fn interpreter(term Term, mut vars map[string]Term) Term {
	match term {
		Print {
			value := interpreter(term.value, mut vars)
			if value is string {
				println(value as string)
			} else if value is int {
				println(value as int)
			} else if value is bool {
				println(value as bool)
			}
			return value
		}
		Str {
			return term.value
		}
		Int {
			return term.value
		}
		Bool {
			return term.value
		}
		Binary {
			lhs := interpreter(term.lhs, mut vars)
			rhs := interpreter(term.rhs, mut vars)
			binary_op := term.op
			return solve_binary_op(lhs, binary_op, rhs)
		}
		If {
			condition := interpreter(term.condition, mut vars) as bool
			if condition {
				return interpreter(term.then, mut vars)
			} else {
				return interpreter(term.otherwise, mut vars)
			}
		}
		Let {
			name := term.name.text
			value := interpreter(term.value, mut vars)
			vars[name] = value
			return interpreter(term.next, mut vars)
		}
		Var {
			var := vars[term.text] or {
				panic("Variable not found")
			}
			return var
		}
		else {
			return ""
		}
	}
}

fn binary_op_from_string(binary_op string) BinaryOp {
	match binary_op {
		'Add' {
			return BinaryOp.add
		}
		'Sub' {
			return BinaryOp.sub
		}
		'Mul' {
			return BinaryOp.mul
		}
		'Div' {
			return BinaryOp.div
		}
		'Rem' {
			return BinaryOp.rem
		}
		'Eq' {
			return BinaryOp.eq
		}
		'Neq' {
			return BinaryOp.neq
		}
		'Lt' {
			return BinaryOp.lt
		}
		'Gt' {
			return BinaryOp.gt
		}
		'Lte' {
			return BinaryOp.lte
		}
		'Gte' {
			return BinaryOp.gte
		}
		'And' {
			return BinaryOp.and
		}
		'Or' {
			return BinaryOp.orop
		}
		else {
			return BinaryOp.@none
		}
	}
}

fn json_to_ast(data_any json2.Any) !Term {
	data := data_any.as_map()
	kind := data["kind"]! as string

	match kind {
		'Print' {
			value := json_to_ast(data["value"]!)!
			return Print{value}
		}
		'Str' {
			value := data["value"]! as string
			return Str{value}
		}
		'Int' {
			value := int(data["value"]! as i64)
			return Int{value}
		}
		'Bool' {
			value := data["value"]! as bool
			return Bool{value}
		}
		'Binary' {
			lhs := json_to_ast(data["lhs"]!)!
			op := binary_op_from_string(data["op"]! as string)
			rhs := json_to_ast(data["rhs"]!)!
			return Binary{lhs, op, rhs}
		}
		'If' {
			condition := json_to_ast(data["condition"]!)!
			then := json_to_ast(data["then"]!)!
			otherwise := json_to_ast(data["otherwise"]!)!
			return If{condition, then, otherwise}
		}
		'Let' {
			name_struct := data["name"]!.as_map()
			name := Parameter{name_struct["text"]! as string}
			value := json_to_ast(data["value"]!)!
			next := json_to_ast(data["next"]!)!
			return Let{name, value, next}
		}
		'Var' {
			text := data["text"]! as string
			return Var{text}
		}
		else {
			return ""
		}
	}
}

fn main() {
	json_txt := os.read_file('files/test.json')!
	data := json2.raw_decode(json_txt)!.as_map()
	term := json_to_ast(data["expression"]!)!
	println(term)
	mut vars := map[string]Term{}
	interpreter(term, mut vars)
}