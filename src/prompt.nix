{
  add_newline = false;
  command_timeout = 1000;
  continuation_prompt = "> ";
  right_format = "";
  format = "$os$hostname$directory$git_branch$git_status$nix_shell$status$time$character";
  palette = "shell-away";
  palettes.shell-away = {
    accent = "#9482ad";
    muted = "#8a8a8a";
    info = "#71979a";
    text = "#e8e8e8";
    bright = "#e8e8e8";
    subtle = "#8a8a8a";
    red = "#e06c75";
    yellow = "#d8a657";
    green = "#98c379";
  };
  os = {
    disabled = false;
    format = "[$symbol]($style)";
    style = "bold accent";
    symbols.NixOS = " ";
  };
  hostname = {
    disabled = false;
    ssh_only = false;
    format = "[$ssh_symbol$hostname]($style) ";
    style = "bold text";
    ssh_symbol = "󰣀 ";
  };
  directory = {
    truncation_length = 1;
    truncation_symbol = "…/";
    truncate_to_repo = true;
    style = "text";
    repo_root_style = "bold accent";
    read_only = " 󰌾";
    read_only_style = "bold bright";
    format = "[  $path]($style)[$read_only]($read_only_style) ";
    repo_root_format = "[  $repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) ";
  };
  git_branch = {
    format = "[$symbol$branch]($style) ";
    style = "bold subtle";
    symbol = " ";
    truncation_length = 16;
    truncation_symbol = "…";
  };
  git_status = {
    format = "([\\[ $all_status$ahead_behind \\]]($style) )";
    style = "bold muted";
    conflicted = "[!$count](bold red) ";
    modified = "[~$count](bold yellow) ";
    staged = "[+$count](bold green) ";
    untracked = "[?$count](bold yellow) ";
    deleted = "[-$count](bold red) ";
    renamed = "[>$count](bold yellow) ";
    stashed = "[*$count](bold muted) ";
    ahead = "[↑$count](bold green) ";
    behind = "[↓$count](bold red) ";
    diverged = "[↕$ahead_count/$behind_count](bold red) ";
  };
  nix_shell = {
    heuristic = false;
    symbol = " ";
    impure_msg = "devshell";
    format = "[⦗ nix:$state ⦘]($style) ";
    style = "bold info";
  };
  status = {
    disabled = false;
    format = "[ ERR $status ](bold red) ";
    symbol = "";
  };
  time = {
    disabled = false;
    format = "[ $time]($style)";
    style = "muted";
    time_format = "%H:%M";
  };
  character = {
    success_symbol = "[](bold green) ";
    error_symbol = "[×](bold red) ";
    vimcmd_symbol = "[](bold subtle) ";
  };
}
