{
  config,
  pkgs,
  ...
}:
{
  programs.firefox = {
    enable = true;
    # profiles."default" = {
    #   settings = {
    #     "media.ffmpeg.vaapi.enabled" = true;
    #     "gfx.webrender.all" = true;
    #   };
    # };
  };
}
