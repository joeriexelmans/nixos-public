{ config, ... }:
{
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_BE.utf8";
    LC_IDENTIFICATION = "nl_BE.utf8";
    LC_MEASUREMENT = "nl_BE.utf8";
    LC_MONETARY = "nl_BE.utf8";
    LC_NAME = "nl_BE.utf8";
    LC_NUMERIC = "nl_BE.utf8";
    LC_PAPER = "nl_BE.utf8";
    LC_TELEPHONE = "nl_BE.utf8";
    LC_TIME = "nl_BE.utf8";
  };
}