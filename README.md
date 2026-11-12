# My-Nixos
My Nixos Setup

This is my Nix configuration setup and organization
I use Wayland protocol with River to use Argen Window Manager 

I am new to the Nixos community

Note: have the unstable channel due to NixOS stable not having "Zig 0.17" at time of writing (11:11:2026) at (21:45) D:M:Y at H:M

https://github.com/dmkhitaryan/river-next-nix-module/issues/37

___
Update, I'm sure there is a much better way, but because I want this to work on the exact same laptop without other commands, I made it so this will work on the normal stable channel by overriding zig to the unstable channel

NGL I had a hard time with this, so I read a lot and took snippets from a lot of different places to glue this together, if you find a better way, let me know please.

THIS MEANS THAT YOU DON'T NEED TO CHANGE YOUR CHANNEL! Like NixOS should be, only the configuration file is changed, no outside commands/configuration needed!
