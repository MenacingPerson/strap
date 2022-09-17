<!--
strap: A simple set of scripts to set up arch
Copyright (C) 2022 Sam

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
-->

# Strap

```sh
pacman-key --init
pacman-key --populate
cfdisk # Partition, make sure to mark EFI partition as boot/esp flag.
pacman -Sy git
git clone https://github.com/Samisafool/strap.git
cd strap
./main <Boot partition> <Root partition> <Home partition>
```
