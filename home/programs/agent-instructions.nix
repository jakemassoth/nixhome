{...}: let
  instructions = ./global-agent-instructions.md;
in {
  programs.pi-coding-agent = {
    enable = true;
    package = null;
    context = instructions;
  };

  programs.claude-code = {
    enable = true;
    package = null;
    context = instructions;
  };
}
