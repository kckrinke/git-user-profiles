## Manage multiple GIT user profiles

Helps to manage different GIT profiles on a per login
session (terminal).

Essentially allows one to use different combinations of
GIT_USER_NAME and GIT_USER_EMAIL in different terminal
sessions at the same time.

This package contains an administrative script to add,
edit and remove GIT profiles: git-user-profiles-admin.

This package also contains a /etc/profile.d script which
prompts the user to select a GIT profile and then exports
the user name and email variables.

The /etc/profile.d script is disabled by default. Edit
the /etc/defaults/git-user-profiles file to enable.

## Copyright and License

Copyright (c) 2014  Kevin C. Krinke <kevin@krinke.ca>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
