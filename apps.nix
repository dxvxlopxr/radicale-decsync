{
  self,
  inputs,
  system,
}:
let
  radicaleWithDecsync = {
    type = "app";
    program = "${self.packages.${system}.radicaleWithDecsync}/bin/radicale";
  };
in
{
  default = radicaleWithDecsync;
  inherit radicaleWithDecsync;
}
