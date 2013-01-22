
module type MEMORY_REPR = sig
	type addr
	val string_of_addr: addr -> string (* standard *)
	val addr_of_string: string -> addr
	val compare: addr -> addr -> int (* standard *)
end

module type SIG = sig

	include MEMORY_REPR

	(*TODO: more ops *)

end

module Default = struct
	type addr = string
	external string_of_addr : string -> addr = "%identity"
	let addr_of_string s =
		if String.length s > 0 && s.[0] = '/' then
			(*TODO: check for path well-fromedness*)
			s
		else
			(*TODO? support relative path?*)
			failwith "Invalid address"
	let compare : addr -> addr -> int = Pervasives.compare

end

module Make (M : MEMORY_REPR) : SIG = struct

	include M

end