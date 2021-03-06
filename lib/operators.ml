(*
 * Copyright (c) 2013 Richard Mortier <mort@cantab.net>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

(** Pipe. *)
external (|>) : 'a -> ('a -> 'b) -> 'b = "%revapply";;

(** Element-wise pipe. *)
let (||>) l f = List.map f l

(** 32 and 64 bit arithmetic and logic operations. *)

(** Addition. *)
let (+++) x y = Int32.add x y
let (++++) x y = Int64.add x y

(** Logical AND. *)
let (&&&) x y = Int32.logand x y
let (&&&&) x y = Int64.logand x y

(** Logical OR. *)
let (|||) x y = Int32.logor x y
let (||||) x y = Int64.logor x y

(** Logical XOR. *)
let (^^^) x y = Int32.logxor x y
let (^^^^) x y = Int64.logxor x y

(** Logical shift-left. *)
let (<<<) x y = Int32.shift_left x y
let (<<<<) x y = Int64.shift_left x y

(** Logical shift-right. *)
let (>>>) x y = Int32.shift_right_logical x y
let (>>>>) x y = Int64.shift_right_logical x y

(** Format `Cstruct.t` *)
let buf_to_string sep buf =
  let open Printf in
  let line_len = 16 in

  let line bs =
    let line = ref "" in
    for i = 0 to (min line_len (Cstruct.len bs)) - 1do
      if i > 0 && i mod 8 == 0 then line := !line ^ " ";
      let c = Cstruct.get_uint8 bs i in
      line :=
        if (Char.code ' ' <= c) && (c <= Char.code '~') then
          sprintf "%s %c." !line (Char.chr c)
        else
          sprintf "%s%02x." !line c
    done;
    !line
  in

  let rec fold f acc = function
    | buf when Cstruct.len buf < line_len ->
      sprintf "%s%s%s" acc sep (line buf)
    | buf ->
      fold f (f acc buf) (Cstruct.shift buf line_len)
  in

  fold
    (fun a v -> sprintf "%s%s%s" a sep (line v))
    ""
    buf
