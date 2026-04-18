# CUPS + common printer drivers + LAN discovery + system-config-printer GUI.

{ config, lib, pkgs, ... }:

{
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint          # ~700 inkjet/laser models (Epson, Canon, HP, Brother…)
      gutenprintBin       # binary Gutenprint plugin for CUPS
      hplip               # HP LaserJet / OfficeJet / DeskJet
      brlaser             # Brother laser printers (HL, DCP, MFC)
      cnijfilter2         # Canon InkJet
      samsung-unified-linux-driver  # Samsung / Samsung-era HP
    ];
    browsing = true;      # discover shared printers on the LAN
  };

  services.system-config-printer.enable = true;
}
