//
// Copyright (C) 2001,2002,2003,2004 Jorge Daza Garcia-Blanes
// Copyright (C) 2010 Andreas Schroeder
//
// This file is part of DrQueue
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

#include <stdio.h>
#include <time.h>

#include "libdrqueue.h"


char *lightwavesg_create (struct lightwavesgi *info) {
  /* This function creates the Lightwave render script based on the information given */
  /* Returns a pointer to a string containing the path of the just created file */
  /* Returns NULL on failure and sets drerrno */

  static char filename[BUFFERLEN];
  char *p;   /* Scene filename without path */
  char scene[MAXCMDLEN];
  char projectdir[MAXCMDLEN];
  char configdir[MAXCMDLEN];
  struct jobscript_info *ji;

  /* Check the parameters */
  if (!strlen(info->scene)) {
    drerrno = DRE_NOTCOMPLETE;
    return NULL;
  }

  dr_copy_path(scene, info->scene, MAXCMDLEN-1);
  dr_copy_path(projectdir, info->projectdir, MAXCMDLEN-1);
  dr_copy_path(configdir, info->configdir, MAXCMDLEN-1);

  p = strrchr(scene,'/');
  p = ( p ) ? p+1 : scene;
  snprintf(filename,BUFFERLEN-1,"%s/%s.%lX",info->scriptdir,p,(unsigned long int)time(NULL));

  // FIXME: Unified path handling
  ji = jobscript_new (JOBSCRIPT_PYTHON, filename);
  if(ji) {

    jobscript_write_heading (ji);
    jobscript_set_variable (ji,"SCENE",scene);
    jobscript_set_variable (ji,"PROJECTDIR",projectdir);
    jobscript_set_variable (ji,"CONFIGDIR",configdir);
    jobscript_set_variable (ji,"RF_OWNER",info->file_owner);
    
    if (strlen(info->format)) {
      jobscript_set_variable (ji,"FFORMAT",info->format);
    }
    if (info->res_x > 0) {
      jobscript_set_variable_int (ji,"RESX",info->res_x);
    }
    if (info->res_y > 0) {
      jobscript_set_variable_int (ji,"RESY",info->res_y);
    }
    if (strlen(info->camera)) {
      jobscript_set_variable (ji,"CAMERA",info->camera);
    }
    
    jobscript_template_write (ji,"lightwave_sg.py");
    jobscript_close (ji);
  } else {
    drerrno = DRE_NOTCOMPLETE;
    return NULL;
  }
  
  return filename;
}

char *lightwavesg_default_script_path (void) {
  static char buf[BUFFERLEN];
  char *p;

  if ((p = getenv("DRQUEUE_TMP")) == NULL) {
    return ("/drqueue_tmp/not/set/");
  }

  if (p[strlen(p)-1] == '/')
    snprintf (buf,BUFFERLEN-1,"%s",p);
  else
    snprintf (buf,BUFFERLEN-1,"%s/",p);

  return buf;
}



