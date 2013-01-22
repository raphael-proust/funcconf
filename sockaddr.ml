
module Make (N. Netaddr.SIG) = struct

module type MEMORY_REPR = sig
	type addr
	val string_of_addr: addr -> string (* standard *)
	val make: N.addr -> int -> addr
	val compare: addr -> addr -> int (* standard *)
	val addr: addr -> N.addr
	val port: addr -> int
end

module type SIG = sig

	include MEMORY_REPR

	(*TODO: open, write, close, with, etc.*)

end

module Default : MEMORY_REPR = struct

	type addr = N.addr * int
	let string_of_addr (a, p) =
		if N.is_net4 a then
			Printf.sprintf "%s:%d" (N.string_of_addr a) p
		else if N.is_net6 a then
			Printf.sprintf "[%s]:%d" (N.string_of_addr a) p
		else
			failwith "Invalid address"
	let make a p = (a, p)
	let addr = fst
	let port = snd

end

module HttpStandard : MEMORY_REPR = struct
	type addr = N.addr
	let string_of_addr a =
		if N.is_net4 a then
			Printf.sprintf "%s:80" (N.string_of_addr a)
		else if N.is_net6 a then
			Printf.sprintf "[%s]:80" (N.string_of_addr a)
		else
			failwith "Invalid address"
	let make a _ = a
	external addr : addr -> N.addr = "%identity"
	let port _ = 80
end

module Make (M : MEMORY_REPR) : SIG = struct

	include M

end


end

	