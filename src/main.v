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
	value i64
}

type Term = Print | Str | string | i64 | Int

fn interpreter(term Term) Term {
	if term is Print {
		value := interpreter(term.value)
		if value is string {
			println(value as string)
		} else {
			println(value as i64)
		}
		return value
	} else if term is Str {
		return term.value
	} else if term is Int {
		return term.value
	}
	return ""
}

fn json_to_ast(data_any json2.Any) !Term {
	data := data_any.as_map()
	kind := data["kind"]! as string
	
	if kind == "Print" {
		value := json_to_ast(data["value"]!)!
		return Print{value}
	} else if kind == "Str" {
		value := data["value"]! as string
		return Str{value}
	} else if kind == "Int" {
		value := data["value"]! as i64
		return Int{value}
	}
	return ""
}

fn main() {
	json_txt := os.read_file('files/test.json')!
	data := json2.raw_decode(json_txt)!.as_map()
	term := json_to_ast(data["expression"]!)!
	println(term)
	interpreter(term)
}