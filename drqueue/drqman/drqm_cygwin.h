// 
// Copyright (C) 2001,2002,2003,2004 Jorge Daza Garcia-Blanes
// 
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
// USA
// 
//
// $Id: drqm_cygwin.h 1101 2005-01-02 01:04:12Z jorge $
//

#ifndef _DRQM_CYGWIN_H_
#define _DRQM_CYGWIN_H_

char *cygwin_file_dialog(char *fname, char *pat, char *message, char save);
char *cygwin_dir_dialog(char *message);

#endif /* _DRQM_CYGWIN_H */

