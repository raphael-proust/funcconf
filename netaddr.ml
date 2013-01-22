module type MEMORY_REPR = sig
	type addr
	val string_of_addr: addr -> string (* standard *)
	val addr_of_string: string -> addr
	val is_net4: addr -> bool
	val is_net6: addr -> bool
	val compare: addr -> addr -> int (* standard *)
end

module type SIG = sig

	include MEMORY_REPR

	val in_range: low:addr -> high:addr -> addr -> bool
	val is_loopback: addr -> bool

end

module Default = struct

	type addr =
		| V4 of int * int * int * int
		| V6 of int * int * int * int * int * int * int * int

	let string_of_addr = function
		| V4 (i1,i2,i3,i4) -> Printf.sprintf "%d.%d.%d.%d" i1 i2 i3 i4
		| V6 (i1,i2,i3,i4,i5,i6,i7,i8) -> Printf.sprintf "%d:%d:%d:%d:%d:%d:%d:%d" i1 i2 i3 i4 i5 i6 i7 i8

	let addr_of_string s =
		try
			try
				Scanf.sscanf s "%d.%d.%d.%d"
					(fun i1 i2 i3 i4 ->
						let range i = 0 <= i && i <= 255 in
						if range i1 && range i2 && range i3 && range i4 then
							V4 (i1,i2,i3,i4)
						else
							failwith "Invalid address"
					)
			with Scanf.Scan_failure _ ->
				Scanf.sscanf s "%d:%d:%d:%d:%d:%d:%d:%d"
					(fun i1 i2 i3 i4 i5 i6 i7 i8 ->
						let range i = 0 <= i && i <= 0xffff in
						if range i1 && range i2 && range i3 && range i4 && range i5 && range i6 && range i7 && range i8 then
							V6 (i1,i2,i3,i4,i5,i6,i7,i8)
						else
							failwith "Invalid address"
					)
		with Scanf.Scan_failure _ ->
			failwith "Invalid address"

	let is_net4 = function
		| V4 _ -> true
		| V6 _ -> false
	let is_v6 = function
		| V6 _ -> true
		| V4 _ -> false

	let compare a1 a2 = Pervasives.compare a1 a2

end

module Net4 = struct

	type addr = string
	let string_of_addr a =
		Printf.sprintf "%d.%d.%d.%d" (Char.code a.[0]) (Char.code a.[1]) (Char.code a.[2]) (Char.code a.[3])
	let addr_of_string s =
		try
			Scanf.sscanf s "%d.%d.%d.%d"
				(fun i0 i1 i2 i3 ->
					let s = String.make 4 (Char.chr i0) in
					s.[1] <- Char.chr i1;
					s.[2] <- Char.chr i2;
					s.[3] <- Char.chr i3
				)
		with Scanf.Scan_failure _ | Invalid_argument "Char.chr" ->
			failwith "Invalid address"

	let compare : string -> string -> int = Pervasives.compare

	let is_net4 _ = true (* hope for this to be inlined *)
	let is_net6 _ = false (*same *)

end

module Make (M: MEMORY_REPR) : SIG = struct

	include M

	let in_range ~low ~high a =
		M.compare low a >= 0 && M.compare a high >= 0

	let low_loopback_v4 = lazy (M.addr_of_string "127.0.0.1")
	let high_loopback_v4 = lazy (M.addr_of_string "127.255.255.254")
	let loopback_v6 = lazy (addr_of_string "0:0:0:0:0:0:0:1")

	let is_loopback a =
		(* this relies on inlining, constant propagation and dead-code elimination to be compiled as a single branch (when [M] is specialized enough).*)
		if is_net4 a then
			M.compare (Lazy.force low_loopback_v4) a >= 0 && M.compare a (Lazy.force high_loopback_v4) >= 0
		else if is_net6 a then
			a = (Lazy.force loopback_v6)
		else
			failwith "Invalid address" (*TODO: better*)

end